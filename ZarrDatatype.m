classdef ZarrDatatype
    %ZARRDATATYPE Datatype of Zarr data
    %   Represents the datatype mapping between MATLAB, Tensorstore, and Zarr

    
    properties(Constant, Hidden)
        % Same-length arrays that represent mapping between 
        % three kinds of datatypes
        MATLABTypes = ["logical", "uint8", "int8", "uint16", "int16",...
            "uint32", "int32", "uint64", "int64", "single", "double"];
        TensorstoreTypes = ["bool", "uint8", "int8", "uint16", "int16",...
            "uint32", "int32", "uint64", "int64", "float32", "float64"];
        ZarrTypes   = ["|b1", "|u1", "|i1", "<u2", "<i2",...
            "<u4", "<i4", "<u8", "<i8", "<f4", "<f8"];
    end
    
    properties (SetAccess = immutable, GetAccess=private, Hidden)
        % Index into datatype arrays
        Index (1,1) int32
    end

    properties (Dependent, SetAccess = immutable)
        % Dependent properties representing the corresponding datatype in
        % Zarr, Tensorstore, and MATLAB
        ZarrType
        TensorstoreType
        MATLABType
    end

    methods (Hidden)
        % "Private" constructor - should not be used directly. 
        % Use from*Type() static methods instead.
        function obj = ZarrDatatype(ind)
            obj.Index = ind;
        end
    end

    methods
        function zType = get.ZarrType(obj)
            % Get the corresponding Zarr datatype
            zType = ZarrDatatype.ZarrTypes(obj.Index);
        end

        function tType = get.TensorstoreType(obj)
            % Get the corresponding Tensorstore datatype
            tType = ZarrDatatype.TensorstoreTypes(obj.Index);
        end

        function mType = get.MATLABType(obj)
            % Get the corresponding MATLAB datatype
            mType = ZarrDatatype.MATLABTypes(obj.Index);
        end
    end

    methods (Static)
        function obj = fromMATLABType(MATLABType)
            % Create a datatype object based on MATLAB datatype name
            arguments
                MATLABType (1,1) string
            end

            validatestring(MATLABType, ZarrDatatype.MATLABTypes);
            ind = find(MATLABType == ZarrDatatype.MATLABTypes);
            obj = ZarrDatatype(ind);
        end

        function obj = fromTensorstoreType(tensorstoreType)
            % Create a datatype object based on Tensorstore datatype name
            arguments
                tensorstoreType (1,1) string
            end

            validatestring(tensorstoreType, ZarrDatatype.TensorstoreTypes);
            ind = find(tensorstoreType == ZarrDatatype.TensorstoreTypes);
            obj = ZarrDatatype(ind);
        end
    end

end