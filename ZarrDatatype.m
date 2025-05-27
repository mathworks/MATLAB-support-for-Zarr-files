classdef ZarrDatatype
    %ZARRDATATYPE Datatype of Zarr data
    %   Represents a datatype of Zarr data and how it is mapped between 
    %   datatypes in MATLAB, Tensorstore, and Zarr

    
    properties(Constant, Hidden)
        % maps between three kinds of datatypes
        MATLABTypes = ["logical", "uint8", "int8", "uint16", "int16",...
            "uint32", "int32", "uint64", "int64", "single", "double"];
        TensorstoreTypes = ["bool", "uint8", "int8", "uint16", "int16",...
            "uint32", "int32", "uint64", "int64", "float32", "float64"];
        ZarrTypes   = ["|b1", "|u1", "|i1", "<u2", "<i2",...
            "<u4", "<i4", "<u8", "<i8", "<f4", "<f8"];
    end

    
    properties (SetAccess = immutable, GetAccess=private, Hidden)
        Index (1,1) int32
    end

    methods (Static)

        function obj = fromMATLABType(MATLABType)
            % Create datatype object from MATLAB datatype
            arguments
                MATLABType (1,1) string
            end

            validatestring(MATLABType, ZarrDatatype.MATLABTypes);
            ind = find(MATLABType == ZarrDatatype.MATLABTypes);
            obj = ZarrDatatype(ind);
        end

        function obj = fromTensorstoreType(tensorstoreType)
            % Create datatype object from Tensorstore datatype
            arguments
                tensorstoreType (1,1) string
            end

            validatestring(tensorstoreType, ZarrDatatype.TensorstoreTypes);
            obj = ZarrDatatype(find(tensorstoreType == ZarrDatatype.TensorstoreTypes));
        end
    end

    methods (Hidden) %(Access=protected)

        % "Private" constructor
        function obj = ZarrDatatype(ind)
            obj.Index = ind;
        end
    end

    methods

        function zType = ZarrType(obj)
            % Get the corresponding Zarr datatype
            zType = ZarrDatatype.ZarrTypes(obj.Index);
        end

        function tType = TensorstoreType(obj)
            % Get the corresponding Tensorstore datatype
            tType = ZarrDatatype.TensorstoreTypes(obj.Index);
        end

        function mType = MATLABType(obj)
            % Get the corresponding MATLAB datatype
            mType = ZarrDatatype.MATLABTypes(obj.Index);
        end
    end
end