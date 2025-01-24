classdef Zarr < handle

    properties (GetAccess = public,SetAccess=protected)
        Path
        ChunkSize
        DsetSize
        MatlabDtype
        Compression
        TstoreSchema
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
            TstoredtypeMap = dictionary(obj.MATLABdatatypes, obj.Tstoredatatypes);
        end

        function ZarrdtypeMap = get.ZarrdtypeMap(obj)
            ZarrdtypeMap = dictionary(obj.MATLABdatatypes, obj.Zarrdatatypes);
        end
            
        function obj = Zarr(path)
            % Python module setup and bootstrapping to MATLAB
            modpath = [pwd '\PythonModule'];
            if count(py.sys.path,modpath) == 0
                insert(py.sys.path,int32(0),modpath);
            end
            
            % clear classes
            mod = py.importlib.import_module('ZarrPy');
            py.importlib.reload(mod);

            obj.Path = path;
        end
        function out = read(obj)
            data = py.ZarrPy.readZarr(obj.Path);
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

        function create(obj, dtype, data_shape, chunk_shape, compression)
            obj.DsetSize = data_shape;
            obj.ChunkSize = chunk_shape;
            obj.MatlabDtype = dtype;
            obj.Tstoredtype = obj.TstoredtypeMap(dtype);
            obj.Zarrdtype = obj.ZarrdtypeMap(dtype);
            obj.Compression = compression;

            disp("While writing....");
            disp(obj.MatlabDtype);
            disp(obj.Tstoredtype);
            disp(obj.Zarrdtype);

            obj.TstoreSchema = py.ZarrPy.createZarr(obj.Path, obj.DsetSize, obj.ChunkSize, obj.Tstoredtype, obj.Zarrdtype);

        end

        function write(obj, data)

            % obj.DsetSize = data_shape;
            % obj.ChunkSize = chunk_shape;
            % obj.MatlabDtype = dtype;
            % obj.Tstoredtype = obj.TstoredtypeMap(dtype);
            % obj.Zarrdtype = obj.ZarrdtypeMap(dtype);
            % 
            % disp("While writing....");
            % disp(obj.MatlabDtype);
            % disp(obj.Tstoredtype);
            % disp(obj.Zarrdtype);

            py.ZarrPy.writeZarr(obj.Path, data);

        end

        function out = readinfo(obj)
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

end