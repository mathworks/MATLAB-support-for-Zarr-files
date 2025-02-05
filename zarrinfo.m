function info = zarrinfo(file_path)
%ZARRINFO Retrieve info about the Zarr array
%   INFO = ZARRINFO(FILEPATH) reads the metadata associated with a Zarr array or
%   group located at FILEPATH, and returns the information in a structure
%   INFO, whose fields are the names of the metdata keys. If FILEPATH is a
%   Zarr array, the value of the field 'node_type' is "array". If FILEPATH
%   is a Zarr group, the value of the field 'node_type' is "group".

%   Copyright 2025 The MathWorks, Inc.

arguments
    file_path {mustBeTextScalar, mustBeNonzeroLengthText}
end

Zarrobj = Zarr(file_path);
info = Zarrobj.readinfo;
end