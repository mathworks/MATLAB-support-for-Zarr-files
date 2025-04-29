function zarrwrite(filepath, data)
%ZARRWRITE Write to a zarr array
%   ZARRWRITE(FILEPATH, DATA) writes the MATLAB variable data (specified by
%   DATA) to the path specified by "filepath".
% The size of DATA must match the size of the Zarr array specified during
% creation.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
    data
end

zarrObj = Zarr(filepath);
zarrObj.write(data)

end