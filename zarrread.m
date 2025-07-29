function data = zarrread(filepath, options)
%ZARRREAD Read data from Zarr array
%   DATA = ZARRREAD(FILEPATH) retrieves all the data from the Zarr array
%   located at FILEPATH. The datatype of DATA is the MATLAB equivalent of 
%   the Zarr datatype of the array located at FILEPATH.
%
%   DATA = ZARRREAD(..., Start=start) retrieves a subset of the data from
%   the Zarr array. Specify start as a row vector of one-based indices of
%   the first elements to be read in each dimension. If you do not specify
%   start, then the function starts reading the dataset from the first
%   index along each dimension.
%
%   DATA = ZARRREAD(..., Count=count) retrieves a subset of the data from
%   the Zarr array. Specify count as a row vector of numbers of elements to
%   be read in each dimension. If you do not specify count, then the
%   function reads data until the end of each dimension.
%
%   DATA = ZARRREAD(..., Stride=stride) retrieves a subset of the data from
%   the Zarr array. Specify stride as a row vector of differences between
%   indices along each dimension. A value of 1 accesses adjacent elements
%   in the corresponding dimension, a value of 2 accesses every other
%   element in the corresponding dimension, and so on. If you do not
%   specify stride, then the function reads data without skipping indices
%   along each dimension.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
    options.Start (1,:) {mustBeNumeric, mustBeInteger, mustBePositive} = [];
    options.Count (1,:) {mustBeNumeric, mustBeInteger, mustBePositive} = [];
    options.Stride (1,:) {mustBeNumeric, mustBeInteger, mustBePositive} = [];
end

zarrObj = Zarr(filepath);
data = zarrObj.read(options.Start, options.Count, options.Stride);
end