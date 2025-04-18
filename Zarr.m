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
            isRemote = matlab.io.internal.vfs.validators.hasIriPrefix(obj.Path);
            if isRemote % Remote file (only S3 support at the moment)
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

        function create(obj, dtype, data_shape, chunk_shape, fillvalue, compression)
            % Function to create the Zarr array

            obj.DsetSize = data_shape;
            obj.ChunkSize = chunk_shape;
            obj.MatlabDatatype = dtype;
            obj.TensorstoreDatatype = obj.TstoredtypeMap(dtype);
            obj.ZarrDatatype = obj.ZarrdtypeMap(dtype);

            if any(obj.ChunkSize > obj.DsetSize)
                error("Chunk size cannot be greater than size of the data to be written.");
            end

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
            if ~isequal(info.shape, datasize(:))
                error("Size of the data to be written does not match.");
            end
            if any(info.chunks > datasize(:))
                error("Chunk size cannot be greater than size of the data to be written.");
            end
            py.ZarrPy.writeZarr(obj.KVStoreSchema, data);
        end

    end

    methods (Access = protected)
        function compression = parseCompression(~,compression)
            % Helper function to validate and parse the compression struct.

            % The compression struct should have an 'id' field.
            if ~isfield(compression, 'id')
                error("Compression id is required");
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
                    error('Unsupported compression id: %s', compression.id);
            end
        end

        function [bucketName, objectPath] = extractS3BucketNameAndPath(~,url)
            % Helper function to extract S3 bucket name and path to file
            % bucketName and objectPath are needed to fill the KVstore hash
            % map for tensorstore.
            % Define the regular expression patterns for matching S3 URLs and URIs
            % S3 URLs can have 3 syntaxes.
            pattern1 = '^https://([^.]+)\.s3\.amazonaws\.com/(.+)$';  % Format 1 : https://mybucket.s3.amazonaws.com/path/to/myfile
            pattern2 = '^https://s3\.amazonaws\.com/([^/]+)/(.+)$';   % Format 2 : https://s3.amazonaws.com/mybucket/path/to/myfile
            pattern3 = '^s3://([^/]+)/(.+)$';                         % Format 3 : s3://mybucket/path/to/myfile

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
            if ~isempty(tokens) && iscell(tokens{1}) && numel(tokens{1}) == 2
                bucketName = tokens{1}{1};
                objectPath = tokens{1}{2};
            else
                error('Invalid S3 URL or URI format');
            end
        end
    end

end