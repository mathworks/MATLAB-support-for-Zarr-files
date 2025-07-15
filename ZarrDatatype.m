classdef ZarrDatatype
    %ZARRDATATYPE Datatype of Zarr data
    %   Represents the datatype mapping between MATLAB, Tensorstore, and Zarr

    % Copyright 2025 The MathWorks, Inc.
    
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
                MATLABType (1,1) string {ZarrDatatype.mustBeMATLABType}
            end

            ind = find(MATLABType == ZarrDatatype.MATLABTypes);
            obj = ZarrDatatype(ind);
        end

        function obj = fromTensorstoreType(tensorstoreType)
            % Create a datatype object based on Tensorstore datatype name
            arguments
                tensorstoreType (1,1) string {ZarrDatatype.mustBeTensorstoreType}
            end

            ind = find(tensorstoreType == ZarrDatatype.TensorstoreTypes);
            obj = ZarrDatatype(ind);
        end

        function obj = fromZarrType(zarrType)
            % Create a datatype object based on Zarr datatype name
            arguments
                zarrType (1,1) string {ZarrDatatype.mustBeZarrType}
            end

            ind = find(zarrType == ZarrDatatype.ZarrTypes);
            obj = ZarrDatatype(ind);
        end

        function mustBeMATLABType(type)
            % Validator for MATLAB types
            mustBeMember(type, ZarrDatatype.MATLABTypes);
        end

        function mustBeTensorstoreType(type)
            % Validator for Tensorstore types
            mustBeMember(type, ZarrDatatype.TensorstoreTypes)
        end

        function mustBeZarrType(type)
            % Validator for Zarr types
            mustBeMember(type, ZarrDatatype.ZarrTypes)
        end
    end

end