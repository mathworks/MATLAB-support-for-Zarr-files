function data = zarrread(file_path)
%ZARRREAD Read data from Zarr array
%   DATA = ZARRREAD(FILEPATH) retrieves all the data from the Zarr array
%   located at FILEPATH.

%   Copyright 2025 The MathWorks, Inc.

Zarrobj = Zarr(file_path);
data = Zarrobj.read;
end