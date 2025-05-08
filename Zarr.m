classdef Zarr < handle
% MATLAB Gateway to Python tensorstore library functions
% An object of the 'Zarr' class is used to read and write a Zarr array.
% An instance of this class represents a Zarr array.

%   Copyright 2025 The MathWorks, Inc.

    properties(GetAccess = public, SetAccess = protected)
        Path
        ChunkSize
        DsetSize
        FillValue
        MatlabDatatype
        Compression
        TensorstoreSchema
        KVStoreSchema       % Schema to represent the storage backend specification (local file, S3, etc)
        isRemote
    end

    properties (Access = protected)
        TensorstoreDatatype
        ZarrDatatype
    end

    properties(Constant, Access = protected)
        MATLABDatatypes = ["logical", "uint8", "int8", "uint16", "int16", "uint32", "int32", "uint64", "int64", "single", "double"];
        TstoreDatatypes = ["bool", "uint8", "int8", "uint16", "int16", "uint32", "int32", "uint64", "int64", "float32", "float64"];
        ZarrDatatypes   = ["|b1",   "|u1",  "|i1",  "<u2",    "<i2",   "<u4",    "<i4",   "<u8",    "<i8",   "<f4",     "<f8"];
        
    end

    properties (Dependent, Access = protected)
        TstoredtypeMap        % hash map from MATLAB datatypes to Tensorstore datatypes
        ZarrdtypeMap          % hash map from MATLAB datatypes to Zarr datatypes.
    end

    methods(Static)
        function pySetup
            % Load the Python library
            
            % Python module setup and bootstrapping to MATLAB
            fullPath = mfilename('fullpath');
            zarrDirectory = fileparts(fullPath);
            modpath = fullfile(zarrDirectory, 'PythonModule');
            % Add the current folder to the Python search path
            if count(py.sys.path,modpath) == 0
                insert(py.sys.path,int32(0),modpath);
            end
            
            % Check if the ZarrPy module is loaded already. If not, load
            % it.
            sys = py.importlib.import_module('sys');
            loadedModules = dictionary(sys.modules);
            if ~loadedModules.isKey("ZarrPy")
                zarrModule = py.importlib.import_module('ZarrPy');
                py.importlib.reload(zarrModule);
            end
        end
    end

    methods 
        
        function TstoredtypeMap = get.TstoredtypeMap(obj)
            % Function to create hash map from MATLAB datatypes to
            % Tensorstore datatypes.
            TstoredtypeMap = dictionary(obj.MATLABDatatypes, obj.TstoreDatatypes);
        end

        function ZarrdtypeMap = get.ZarrdtypeMap(obj)
            % Function to create hash map from MATLAB datatypes to
            % Zarr datatypes.
            ZarrdtypeMap = dictionary(obj.MATLABDatatypes, obj.ZarrDatatypes);
        end
            
        function obj = Zarr(path)
            % Load the Python library
            Zarr.pySetup;
            
            obj.Path = path;
            obj.isRemote = matlab.io.internal.vfs.validators.hasIriPrefix(obj.Path);
            if obj.isRemote % Remote file (only S3 support at the moment)
                % Extract the S3 bucket name and path
                [bucketName, objectPath] = obj.extractS3BucketNameAndPath(obj.Path);
                % Create a Python dictionary for the KV store driver
                RemoteStoreSchema = dictionary(["driver", "bucket", "path"], ["s3", bucketName, objectPath]);
                obj.KVStoreSchema = py.dict(RemoteStoreSchema);
                
            else % Local file
                FileStoreSchema = dictionary(["driver", "path"], ["file", obj.Path]);
                obj.KVStoreSchema = py.dict(FileStoreSchema);
            end
        end

        
        function data = read(obj)
            % Function to read the Zarr array

            % If the Zarr array is local, verify that it is a valid folder
            % Enabling this check only for local Zarr files and S3 hosted
            % Zarr files in the s3:// syntax (for now) because https S3
            % links will fail this check even if they are valid.
            if ~startsWith(obj.Path, 'http')
                if ~isfile(fullfile(obj.Path, '.zarray'))
                    error("MATLAB:Zarr:invalidZarrObject",...
                        "Invalid file path. File path must refer to a valid Zarr array.");
                end
            end

            ndArrayData = py.ZarrPy.readZarr(obj.KVStoreSchema);
            % Identify the Python datatype
            obj.TensorstoreDatatype = string(ndArrayData.dtype.name);

            % Extract the corresponding MATLAB datatype key from the
            % dictionary
            TstoredtypeTable = entries(obj.TstoredtypeMap);
            obj.MatlabDatatype = TstoredtypeTable.Key(TstoredtypeTable.Value == obj.TensorstoreDatatype);

            obj.ZarrDatatype = obj.ZarrdtypeMap(obj.MatlabDatatype);

            % Convert the numpy array to MATLAB array
            data = cast(ndArrayData, obj.MatlabDatatype);
        end

        function create(obj, dtype, data_size, chunk_size, fillvalue, compression)
            % Function to create the Zarr array

            obj.DsetSize = int64(data_size);
            obj.ChunkSize = int64(chunk_size);
            obj.MatlabDatatype = dtype;
            obj.TensorstoreDatatype = obj.TstoredtypeMap(dtype);
            obj.ZarrDatatype = obj.ZarrdtypeMap(dtype);

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
                obj.FillValue = cast(fillvalue, obj.MatlabDatatype);
            end
            
            % The Python function returns the Tensorstore schema, but we
            % do not use it for anything at the moment.
            obj.TensorstoreSchema = py.ZarrPy.createZarr(obj.KVStoreSchema, py.numpy.array(obj.DsetSize),...
                py.numpy.array(obj.ChunkSize), obj.TensorstoreDatatype, ...
                 obj.ZarrDatatype, obj.Compression, obj.FillValue);
            %py.ZarrPy.temp(py.numpy.array([1, 1]), py.numpy.array([2, 2]))
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
            
            py.ZarrPy.writeZarr(obj.KVStoreSchema, data);
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

        function [bucketName, objectPath] = extractS3BucketNameAndPath(~,url)
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
            bucketGroup = [1, 1, 1, 1, 1, 1];
            pathGroup   = [3, 2, 2, 2, 2, 2];
            
            % Iterate through the patterns and identify the pattern which matches the
            % URI. Extract the bucket name and the path.
            for patternIdx = 1:numel(patterns)
                tokens = regexp(url, patterns{patternIdx}, 'tokens');
                if ~isempty(tokens)
                    t = tokens{1};
                    bucketName = t{bucketGroup(patternIdx)};
                    objectPath = t{pathGroup(patternIdx)};
                    return;
                end
            end
            
            error("MATLAB:Zarr:invalidS3URL","Invalid S3 URI.");
        end
    end

end