function data = zarrread(filepath)
%ZARRREAD Read data from Zarr array
%   DATA = ZARRREAD(FILEPATH) retrieves all the data from the Zarr array
%   located at FILEPATH.
% The datatype of DATA is the MATLAB equivalent of the Zarr datatype of the
% array located at FILEPATH.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
end

zarrObj = Zarr(filepath);
data = zarrObj.read;
end