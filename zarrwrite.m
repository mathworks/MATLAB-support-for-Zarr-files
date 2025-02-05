function zarrwrite(file_path, data)
%ZARRWRITE Write to a zarr array
%   ZARRWRITE(FILEPATH, DATA) writes the MATLAB variable data at the path
%   specified by FILEPATH

%   Copyright 2025 The MathWorks, Inc.

arguments
    file_path {mustBeTextScalar, mustBeNonzeroLengthText}
    data
end


Zarrobj = Zarr(file_path);
% data_shape = size(data);
% dtype = class(data);
Zarrobj.write(data)

end