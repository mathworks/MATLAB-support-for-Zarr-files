function data = zarrread(filepath)
%ZARRREAD Read data from Zarr array
%   DATA = ZARRREAD(FILEPATH) retrieves all the data from the Zarr array
%   located at FILEPATH.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
end

% If the location does not exist, throw an error.
if ~isfolder(filepath)
    error("Invalid location.")
end

zarrObj = Zarr(filepath);
data = zarrObj.read;
end