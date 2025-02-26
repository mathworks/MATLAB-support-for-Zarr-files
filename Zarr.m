classdef Zarr < handle
% MATLAB Gateway to Python tensorstore library functions

%   Copyright 2025 The MathWorks, Inc.

    properties (GetAccess = public,SetAccess=protected)
        Path
        ChunkSize
        DsetSize
        FillValue
        MatlabDtype
        Compression
        TstoreSchema
        KVstoreschema
    end

    properties (Access = protected)
        Tstoredtype
        Zarrdtype
    end

    properties(Constant, Access = protected)
        MATLABdatatypes = ["logical", "uint8", "int8", "uint16", "int16", "uint32", "int32", "uint64", "int64", "single", "double"];
        Tstoredatatypes = ["bool", "uint8", "int8", "uint16", "int16", "uint32", "int32", "uint64", "int64", "float32", "float64"];
        Zarrdatatypes   = ["|b1",   "|u1",  "|i1",  "<u2",    "|i2",   "|u4",    "|i4",   "|u8",    "|i8",   "<f4",     "<f8"];
        
    end

    properties (Dependent, Access = protected)
        TstoredtypeMap
        ZarrdtypeMap 
    end


    methods 
        
        function TstoredtypeMap = get.TstoredtypeMap(obj)
            % Function to create hash map from MATLAB datatypes to
            % Tensorstore datatypes.
            TstoredtypeMap = dictionary(obj.MATLABdatatypes, obj.Tstoredatatypes);
        end

        function ZarrdtypeMap = get.ZarrdtypeMap(obj)
            % Function to create hash map from MATLAB datatypes to
            % Zarr datatypes.
            ZarrdtypeMap = dictionary(obj.MATLABdatatypes, obj.Zarrdatatypes);
        end
            
        function obj = Zarr(path)
            % Load the Python library and create the Zarr object
            
            % Python environment out of process
            % pe = pyenv;
            % if pe.Status == 'NotLoaded'
            %     pyenv(ExecutionMode="OutOfProcess");
            % end
            
            % Python module setup and bootstrapping to MATLAB
            modpath = [pwd '\PythonModule'];
            if count(py.sys.path,modpath) == 0
                insert(py.sys.path,int32(0),modpath);
            end
            
            % clear classes
            mod = py.importlib.import_module('ZarrPy');
            py.importlib.reload(mod);

            obj.Path = path;
            isRemote = matlab.io.internal.vfs.validators.hasIriPrefix(obj.Path);
            if isRemote % Remote file (only S3 support at the moment)
                [bucketName, objectPath] = obj.extractS3BucketNameAndPath(obj.Path);
                RemoteStoreSchema = dictionary(["driver", "bucket", "path"], ["s3", bucketName, objectPath]);
                obj.KVstoreschema = py.dict(RemoteStoreSchema);
                
            else        % Local file
                FileStoreSchema = dictionary(["driver", "path"], ["file", obj.Path]);
                obj.KVstoreschema = py.dict(FileStoreSchema);
            end
            
        end

        % function delete(obj)
        %     disp("In Destructor");
        %     % pyenv(ExecutionMode="InProcess");
        % end

        function out = read(obj)
            % Function to read the Zarr array

            data = py.ZarrPy.readZarr(obj.KVstoreschema);
            % Identify the Python datatype
            obj.Tstoredtype = string(data.dtype.name);

            % Extract the corresponding MATLAB datatype key from the
            % dictionary
            P = entries(obj.TstoredtypeMap);
            obj.MatlabDtype = P.Key(P.Value == obj.Tstoredtype);

            obj.Zarrdtype = obj.ZarrdtypeMap(obj.MatlabDtype);

            % Convert the numpy array to MATLAB array
            out = feval(obj.MatlabDtype, data);

            disp("While reading....");
            disp(obj.MatlabDtype);
            disp(obj.Tstoredtype);
            disp(obj.Zarrdtype);
            
        end

        function create(obj, dtype, data_shape, chunk_shape, fillvalue, compression)
            % Function to create the Zarr array

            obj.DsetSize = data_shape;
            obj.ChunkSize = chunk_shape;
            obj.MatlabDtype = dtype;
            obj.Tstoredtype = obj.TstoredtypeMap(dtype);
            obj.Zarrdtype = obj.ZarrdtypeMap(dtype);

            % If compression is empty, it means no compression
            if isempty(compression)
                obj.Compression = py.None;
            else
                obj.Compression = obj.parseCompression(compression);
            end

            % Fill Value
            if (isempty(fillvalue))
                obj.FillValue = py.None;
            else
                obj.FillValue = feval(obj.MatlabDtype, fillvalue);
            end
            
           
            disp("While writing....");
            disp(obj.MatlabDtype);
            disp(obj.Tstoredtype);
            disp(obj.Zarrdtype);

            obj.TstoreSchema = py.ZarrPy.createZarr(obj.KVstoreschema, obj.DsetSize, obj.ChunkSize, obj.Tstoredtype, ...
                obj.Zarrdtype, obj.Compression, obj.FillValue);

        end

        function write(obj, data)
            % Function to write to the Zarr array

            py.ZarrPy.writeZarr(obj.KVstoreschema, data);

        end

        function out = readinfo(obj)
            % Function to read the Zarr metadata

            file_path = obj.Path;
            if isfile(fullfile(file_path, '.zarray'))
                infodata = fileread(fullfile(file_path, '.zarray'));
                out = jsondecode(infodata);
                out.node_type = 'array';
            elseif isfile(fullfile(file_path, '.zgroup'))
                infodata = fileread(fullfile(file_path, '.zgroup'));
                out = jsondecode(infodata);
                out.node_type = 'group';
            elseif isfile(fullfile(file_path, 'zarr.json'))
                infodata = fileread(fullfile(file_path, 'zarr.json'));
                out = jsondecode(infodata);
            else
                error("Not a valid Zarr array or group");
            end
        end

    end

    methods (Access = protected)
        function compression = parseCompression (~,compression)
            % Helper function to validate and parse the compression struct.

            if ~isfield(compression, 'id')
                error("Compression id is required");
            end
            switch(compression.id)
                case {"zlib", "gzip", "bz2", "zstd"}
                    if ~isfield(compression, 'level')
                        compression.level = 1;
                    end
                case "blosc"
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
                    error('Unsupported compression id: %s', compression.id);
            end
        end

        function [bucketName, objectPath] = extractS3BucketNameAndPath(~,url)
            % Helper function to extract S3 bucket name and path to file
            % Define the regular expression patterns for matching S3 URLs and URIs
            pattern1 = '^https://([^.]+)\.s3\.amazonaws\.com/(.+)$';  % Format 1
            pattern2 = '^https://s3\.amazonaws\.com/([^/]+)/(.+)$';   % Format 2
            pattern3 = '^s3://([^/]+)/(.+)$';                         % Format 3

            % Try matching the first pattern
            tokens = regexp(url, pattern1, 'tokens');

            % If the first pattern does not match, try the second pattern
            if isempty(tokens)
                tokens = regexp(url, pattern2, 'tokens');
            end

            % If the second pattern does not match, try the third pattern
            if isempty(tokens)
                tokens = regexp(url, pattern3, 'tokens');
            end

            % Extract the bucket name and object path from the tokens
            if ~isempty(tokens)
                bucketName = tokens{1}{1};
                objectPath = tokens{1}{2};
            else
                error('Invalid S3 URL or URI format');
            end
        end
    end

end