function data = zarrread(filepath, options)
%ZARRREAD Read data from Zarr array
%   DATA = ZARRREAD(FILEPATH) retrieves all the data from the Zarr array
%   located at FILEPATH. The datatype of DATA is the MATLAB equivalent of 
%   the Zarr datatype of the array located at FILEPATH.
% 
%   DATA = ZARRREAD(FILEPATH, Start=start) retrieves a subset of the data 
%   from the Zarr array located at FILEPATH. Start is a row vector of 
%   one-based indices of the first element to be read in each dimension. 
% 
%   DATA = ZARRREAD(FILEPATH, Count=count) retrieves a subset of the data 
%   from the Zarr array located at FILEPATH. Count is a row vector
%   of number of elements to be read in each dimension. 
% 
%   DATA = ZARRREAD(FILEPATH, Stride=stride) retrieves a subset of the data 
%   from the Zarr array located at FILEPATH. Stride is a row vector of 
%   spaces between indices along each dimension. A value of 1 accesses 
%   adjacent elements in the corresponding dimension, a value of 2
%   accesses every other element in the corresponding dimension, etc.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
    options.Start (1,:) {mustBeInteger, mustBePositive} = [];
    options.Count (1,:) {mustBeInteger, mustBePositive} = [];
    options.Stride (1,:) {mustBeInteger, mustBePositive} = [];
end

zarrObj = Zarr(filepath);
data = zarrObj.read(options.Start, options.Count, options.Stride);
end