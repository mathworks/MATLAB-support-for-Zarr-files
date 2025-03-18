function zarrwrite(filepath, data)
%ZARRWRITE Write to a zarr array
%   ZARRWRITE(FILEPATH, DATA) writes the MATLAB variable data at the path
%   specified by FILEPATH

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
    data
end

% If the location does not exist, throw an error.
if ~isfolder(filepath)
    error("Invalid location.")
end


Zarrobj = Zarr(filepath);
Zarrobj.write(data)

end