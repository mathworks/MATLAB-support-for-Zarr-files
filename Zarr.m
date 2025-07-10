classdef Zarr < handle
% MATLAB Gateway to Python tensorstore library functions
% An object of the 'Zarr' class is used to read and write a Zarr array.
% An instance of this class represents a Zarr array.

%   Copyright 2025 The MathWorks, Inc.

    properties(GetAccess = public, SetAccess = protected)
        Path (1,1) string
        ChunkSize
        DsetSize
        FillValue
        Datatype
        Compression
        TensorstoreSchema
        KVStoreSchema % Schema to represent the storage backend specification (local file, S3, etc)
        isRemote
    end

    methods(Static)
        function pySetup
            % Set up Python path
            
            % Python module setup and bootstrapping to MATLAB
            fullPath = mfilename('fullpath');
            zarrDirectory = fileparts(fullPath);
            zarrPyPath = fullfile(zarrDirectory, 'PythonModule');
            % Add ZarrPy to the Python search path if it is not there
            % already
            if count(py.sys.path,zarrPyPath) == 0
                insert(py.sys.path,int32(0),zarrPyPath);
            end
        end

        function zarrPy = ZarrPy()
            % Get ZarrPy Python module

            % Python will compile and cache the module after the first call
            % to import_module, so there is no harm in making this call
            % multiple times.
            zarrPy = py.importlib.import_module('ZarrPy');
        end

        function pyReloadInProcess()
            % Reload ZarrPy module after it has been modified (for
            % In-Process Python only). Need to do `clear classes` before
            % this call. For Out-of-Process Python, can just use
            % `terminate(pyenv)` instead.

            % make sure the python module is on the path
            Zarr.pySetup()

            % reload
            py.importlib.reload(Zarr.ZarrPy);
        end

        function isZarray = isZarrArray(path)
            % Given a path, determine if it is a Zarr array

            isZarray = isfile(fullfile(path, '.zarray'));
        end

        function isZgroup = isZarrGroup(path)
            % Given a path, determine if it is a Zarr group

            isZgroup = isfile(fullfile(path, '.zgroup'));
        end

        function newParams = processPartialReadParams(params, dims,...
                defaultValues, paramName)
            % Process the parameters for partial read (Start, Stride,
            % Count)
            arguments (Input)
                params % Start/Stride/Count parameter to be validated
                dims (1,:) double  % Zarr array dimensions
                defaultValues (1,:) 
                paramName (1,1) string 
            end

            arguments (Output)
                newParams (1,:) int64 % must be integers for tensorstore
            end
            
            if isempty(params)
                newParams = defaultValues;
                return
            end

            % Allow using a scalar value for indexing into row or column
            % datasets
            if isscalar(params) && any(dims==1) && numel(dims)==2
                newParams = defaultValues;
                % use the provided value for the non-scalar dimension
                newParams(dims~=1) = params;
                return
            end

            if numel(params) ~= numel(dims)
                error("MATLAB:Zarr:badPartialReadDimensions",...
                    "Number of elements in " +...
                    "%s must be the same "+...
                    "as the number of Zarr array dimensions.",...
                    paramName)
            end

            newParams = params;
        end

        function resolvedPath = getFullPath(path)
            % Given a path, resolves it to a full path. The trailing
            % directories do not have to exist.

            arguments (Input)
                path (1,1) string
            end

            if path == ""
                resolvedPath = pwd;
                return
            end

            resolvedPath = matlab.io.internal.filesystem.resolvePath(path).ResolvedPath;

            if resolvedPath == ""
                % If the given path does not exist, it is likely due to
                % trailing directories not existing yet. Try to resolve its
                % parent path.
                [pathToParentFolder, child, ext] = fileparts(path);

                if pathToParentFolder==path
                    % If the path was not resolved and it is the same as
                    % its parent path, then we have failed to resolve a
                    % full path. This likely indicates a problem.
                    resolvedPath = "";
                    return
                end

                % Resolve parent directory's path, and append child directory.
                resolvedParentPath = Zarr.getFullPath(pathToParentFolder);
                resolvedPath = fullfile(resolvedParentPath, child+ext);
            end
        end

        function existingParent = getExistingParentFolder(path)
            % Given a full path where some trailing directories might not yet
            % exist, determine the longest prefix path that does exist

            arguments (Input)
                path (1,1) string
            end

            if isfolder(path)
                % If the full path exists, we are done.
                existingParent = path;
                return
            end

            % Get the parent path
            [pathToParentFolder, ~, ~] = fileparts(path);
            if pathToParentFolder == path
                % If the path is not an existing folder and it is the same
                % as its parent path, we have failed to find an existing
                % parent folder. This likely indicates a problem.
                existingParent = "";
                return
            end
            % Continue recursing until an existing parent path is found
            existingParent = Zarr.getExistingParentFolder(pathToParentFolder);

        end

        function createGroup(pathToGroup)
            % Create a Zarr group including creating the directory (if
            % needed) and the .zgroup file. Assumes the parent directory
            % exists

            if ~isfolder(pathToGroup)
                mkdir(pathToGroup)
            end

            % Currently we support only Zarr v2
            groupJSON = jsonencode(struct("zarr_format", "2"));

            % Write .zgroup file
            groupFile = fullfile(pathToGroup, ".zgroup");
            fid = fopen(groupFile, 'w');
            if fid == -1
                error("MATLAB:Zarr:fileOpenFailure",...
                    "Could not open file ""%s"" for writing.",groupFile);
            end
            closeFile = onCleanup(@() fclose(fid));

            fwrite(fid, groupJSON, 'char');
        end

        function makeZarrGroups(existingParentPath, newGroupsPath)
            % Create a hierarchy of nested Zarr groups for all directories
            % in newGroupsPath. For example, if existingParentPath is
            % "/Users/jsmith/Documents" and newGroupsPath is
            % "myfile.zarr/A/B", the following directories will be made
            % into Zgroups:
            %    /Users/jsmith/Documents/myfile.zarr/
            %    /Users/jsmith/Documents/myfile.zarr/A
            %    /Users/jsmith/Documents/myfile.zarr/A/B
            %
            % The existingParentPath and newGroupsPath should combine to
            % create an absolute path to the most nested zarr group to be
            % created
            
            arguments (Input)
                existingParentPath (1,1) string
                newGroupsPath (1,1) string
            end

            newGroups = split(newGroupsPath, filesep);

            for group = newGroups'
                if group == ""
                    continue
                end
                pathToNewGroup = fullfile(existingParentPath, group);
                Zarr.createGroup(pathToNewGroup);
                existingParentPath = pathToNewGroup;
            end

        end

        function [bucketName, objectPath] = extractS3BucketNameAndPath(url)
            % Helper function to extract S3 bucket name and path to file
            % bucketName and objectPath are needed to fill the KVstore hash
            % map for tensorstore.
            % Define the regular expression patterns for matching S3 URLs and URIs
            % S3 URLs can have the following patterns.
            patterns = { ...
                '^https://([^.]+)\.s3\.([^.]+)\.amazonaws\.com/(.+)$', ... % 1: AWS virtual-hosted, region (https://mybucket.s3.us-west-2.amazonaws.com/path/to/myZarrFile)
                '^https://([^.]+)\.s3\.amazonaws\.com/(.+)$', ...          % 2: AWS virtual-hosted, no region (https://mybucket.s3.amazonaws.com/path/to/myZarrFile)
                '^https://([^.]+)\.s3\.[^/]+/(.+)$', ...                   % 3: Custom endpoint virtual-hosted (https://mybucket.s3.custom-endpoint.org/path/to/myZarrFile)
                '^https://s3\.amazonaws\.com/([^/]+)/(.+)$', ...           % 4: AWS path-style (https://s3.amazonaws.com/mybucket/path/to/myZarrFile)
                '^https://s3\.[^/]+/([^/]+)/(.+)$', ...                    % 5: Custom endpoint path-style (https://s3.eu-central-1.example.edu/mybucket/path/to/myZarrFile)
                '^s3://([^/]+)/(.+)$' ...                                  % 6: S3 URI (s3://mybucket/path/to/myZarrFile)
                };

            % For each pattern, specify which group is bucket and which is path
            % regexp will extract multiple tokens from the patterns above.
            % For each pattern, the indices below denote the location of
            % the bucket and the path name.
            bucketIdx = [1, 1, 1, 1, 1, 1];
            pathIdx   = [3, 2, 2, 2, 2, 2];

            % Iterate through the patterns and identify the pattern which matches the
            % URI. Extract the bucket name and the path.
            for patternIdx = 1:numel(patterns)
                tokens = regexp(url, patterns{patternIdx}, 'tokens');
                if ~isempty(tokens)
                    t = tokens{1};
                    bucketName = t{bucketIdx(patternIdx)};
                    objectPath = t{pathIdx(patternIdx)};
                    return;
                end
            end

            error("MATLAB:Zarr:invalidS3URL","Invalid S3 URI format.");
        end
    end

    methods 
                    
        function obj = Zarr(path)
            % Load the Python library
            Zarr.pySetup;
            
            obj.Path = path;
            obj.isRemote = matlab.io.internal.vfs.validators.hasIriPrefix(obj.Path);
            if obj.isRemote % Remote file (only S3 support at the moment)
                % Extract the S3 bucket name and path
                [bucketName, objectPath] = Zarr.extractS3BucketNameAndPath(obj.Path);
                % Create a Python dictionary for the KV store driver
                obj.KVStoreSchema = Zarr.ZarrPy.createKVStore(obj.isRemote, objectPath, bucketName);
                
            else % Local file
                % Use full path
                obj.Path = Zarr.getFullPath(path);
                if obj.Path == ""
                    % Error out if the full path could not be resolved
                    error("MATLAB:Zarr:invalidPath",...
                        "Unable to access path ""%s"".", path)
                end
                obj.KVStoreSchema = Zarr.ZarrPy.createKVStore(obj.isRemote, obj.Path);
            end
        end

        
        function data = read(obj, start, count, stride)
            % Function to read the Zarr array

            % If the Zarr array is local, verify that it is a valid folder
            % Enabling this check only for local Zarr files and S3 hosted
            % Zarr files in the s3:// syntax (for now) because https S3
            % links will fail this check even if they are valid.
            if ~startsWith(obj.Path, 'http')
                if ~Zarr.isZarrArray(obj.Path)
                    error("MATLAB:Zarr:invalidZarrObject",...
                        "Invalid file path. File path must refer to a valid Zarr array.");
                end
            end

            % Validate partial read parameters
            info = zarrinfo(obj.Path);
            numDims = numel(info.shape);
            start = Zarr.processPartialReadParams(start, info.shape,...
                ones([1,numDims]), "Start");
            stride = Zarr.processPartialReadParams(stride, info.shape,...
                ones([1,numDims]), "Stride"); 
            maxCount = (int64(info.shape') - start + 1)./stride; % has to be a row vector
            count = Zarr.processPartialReadParams(count, info.shape,...
                maxCount, "Count"); 

            % Convert partial read parameters to tensorstore-style
            % indexing
            start = start - 1; % tensorstore is 0-based
            % Tensorstore uses end index instead of count
            % (it does NOT include element at the end index)
            endInds = start + stride.*count;

            % Read the data
            ndArrayData = Zarr.ZarrPy.readZarr(obj.KVStoreSchema,...
                start, endInds, stride);

            % Store the datatype
            obj.Datatype = ZarrDatatype.fromTensorstoreType(ndArrayData.dtype.name);

            % Convert the numpy array to MATLAB array
            data = cast(ndArrayData, obj.Datatype.MATLABType);
        end

        function create(obj, dtype, data_size, chunk_size, fillvalue, compression)
            % Function to create the Zarr array

            obj.DsetSize = int64(data_size);
            obj.ChunkSize = int64(chunk_size);
            obj.Datatype = ZarrDatatype.fromMATLABType(dtype);

            % If compression is empty, it means no compression
            if isempty(compression)
                obj.Compression = py.None;
            else
                obj.Compression = obj.parseCompression(compression);
            end

            % Fill Value
            if isempty(fillvalue)
                obj.FillValue = py.None;
            else
                % Fill value must be of the same datatype as data.
                if ~isa(fillvalue, dtype)
                    error("MATLAB:zarrcreate:invalidFillValueType",...
                        "Fill value must have the same data type (""%s"") as the Zarr array.",...
                        dtype)
                end
                obj.FillValue = fillvalue;
            end
            
            % see how much of the provided path exists already 
            existingParentPath = Zarr.getExistingParentFolder(obj.Path);

            if existingParentPath == ""
                % If no existing parent folder was found, it likely
                % indicates an issue (esp. for remote paths) - maybe the
                % path is invalid (non-existent bucket, etc.) or
                % connection/permission issue caused none of the parent
                % directories on the path to be recognized as existing
                % folders.
                error("MATLAB:Zarr:invalidPath",...
                    "Unable to access path ""%s"".", obj.Path)
            end

            % The Python function returns the Tensorstore schema, but we
            % do not use it for anything at the moment.
            obj.TensorstoreSchema = Zarr.ZarrPy.createZarr(obj.KVStoreSchema, py.numpy.array(obj.DsetSize),...
                py.numpy.array(obj.ChunkSize), obj.Datatype.TensorstoreType, ...
                 obj.Datatype.ZarrType, obj.Compression, obj.FillValue);
            %py.ZarrPy.temp(py.numpy.array([1, 1]), py.numpy.array([2, 2]))

            % if new directories were created as part of creating a
            % Zarr array, we need to make them into Zarr groups.
            newDirs = extractAfter(obj.Path, existingParentPath);
            % the last directory is a Zarr array, ones before should be
            % Zarr groups
            [newGroups, ~,~] = fileparts(newDirs);
            if newGroups ~= ""
                Zarr.makeZarrGroups(existingParentPath, newGroups);
            end


        end

        function write(obj, data)
            % Function to write to the Zarr array

            % Read the Array info
            info = zarrinfo(obj.Path);
            datasize = size(data);
            % Verify if the data to be written is of correct dimensions
            if isscalar(info.shape)
                isCorrectShape = (numel(data) == info.shape);
                
            else
                isCorrectShape = isequal(info.shape, datasize(:));
            end

            if ~isCorrectShape
                error("MATLAB:Zarr:sizeMismatch",...
                    "Unable to write data. Size of the data to be written must match size of the array.");
            end
            
            Zarr.ZarrPy.writeZarr(obj.KVStoreSchema, data);
        end

    end

    methods (Access = protected)
        function compression = parseCompression(~,compression)
            % Helper function to validate and parse the compression struct.

            % The compression struct should have an 'id' field.
            if ~isfield(compression, 'id')
                error("MATLAB:Zarr:missingCompressionID",...
                    "Compression structure must contain an id field. Specify compression id as ""zlib"", ""gzip"", ""blosc"", ""bz2"", or ""zstd"".");
            end
            switch(compression.id)
                case {"zlib", "gzip", "bz2", "zstd"}
                    % Only 'level' optional field for these compressions
                    if ~isfield(compression, 'level')
                        compression.level = 1;
                    end
                case "blosc"
                    % Fields for blosc compression
                    if ~isfield(compression, 'cname')
                        compression.cname = 'lz4';
                    end
                    if ~isfield(compression, 'clevel')
                        compression.clevel = 5;
                    end
                    if ~isfield(compression, 'shuffle')
                        compression.shuffle = -1;
                    end
                otherwise
                    error("MATLAB:Zarr:invalidCompressionID",...
                        "Invalid compression id. Specify compression id as ""zlib"", ""gzip"", ""blosc"", ""bz2"", or ""zstd"".");
            end
        end

 
    end

end