function info = zarrinfo(filepath)
%ZARRINFO Retrieve info about the Zarr array
%   INFO = ZARRINFO(FILEPATH) reads the metadata associated with a Zarr array or
%   group located at FILEPATH, and returns the information in a structure
%   INFO, whose fields are the names of the metdata keys. If FILEPATH is a
%   Zarr array, the value of the field 'node_type' is "array". If FILEPATH
%   is a Zarr group, the value of the field 'node_type' is "group".

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
end

% If the location does not exist, throw an error.
if ~isfolder(filepath)
    error("Invalid location.")
end

Zarrobj = Zarr(filepath);
info = Zarrobj.readinfo;
end