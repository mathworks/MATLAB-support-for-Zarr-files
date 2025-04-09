function zarrwrite(filepath, data)
%ZARRWRITE Write to a zarr array
%   ZARRWRITE(FILEPATH, DATA) writes the MATLAB variable data to the path
%   specified by FILEPATH

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
    data
end

zarrObj = Zarr(filepath);
zarrObj.write(data)

end