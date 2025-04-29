function zarrcreate(filepath, datashape, options)
%ZARRCREATE Create Zarr array.
%   ZARRCREATE(FILEPATH, DATASHAPE, Param1, Value1, ...) Create a Zarr
%   array at the path specified by "filepath" and of the dimensions specified
%   by DATASHAPE. 
% If "filepath" is a full path name, the function creates all
% intermediate groups that do not already exist. If "filepath" exists
% already, the contents are overwritten.
% 
% Name - Value Pairs
% ------------------
%     Datatype                - One of "double", "single", "uint64",
%                               "int64", "uint32", "int32", "uint16",
%                               "int16", "uint8", "int8", or "string".
%                               Defaults to "double".
% 
%     ChunkSize               - Defines chunking layout specified as an
%                               array of integers.
%                               Default is [], which specifies no chunking.
% 
%     FillValue               - Defines the Fill value for numeric arrays.
%                               Default is [], which specifies no fill
%                               value.
% 
%     Compression             - Primary compression codec used to
%                               compress the Zarr array, specified as a
%                               struct containing an "id" field. The fields
%                               for the struct are as follows: "id"    -
%                               The accepted values are "zlib", "gzip",
%                                         "blosc", "bz2", "zstd" or []
%                                         (default) for no compression.
%                               Optional Fields:
%                                 "level" - Compression level, specified as
%                                           an integer.
%                                           Valid for all but "blosc"
%                                           compression. The default value
%                                           is 1. The accepted integer
%                                           values for different
%                                           compressions are: zlib - [0, 9]
%                                           gzip - [0, 9] bz2  - [1, 9]
%                                           zstd - [-131072, 22]
%                                 "cname" - Valid only for "blosc"
%                                           compression. Name of
%                                           compression scheme for blosc
%                                           compression, specified as one
%                                           of these values: "blosclz",
%                                           "lz4", "lz4hc", "snappy",
%                                           "zlib", "zstd". "zstd" is the
%                                           same scheme as "lz4".
%                                 "clevel" - Valid only for "blosc"
%                                            compression. Compression level
%                                            for blosc compression,
%                                            specified as an integer in the
%                                            range [0, 9]. The default
%                                            value is 5.
%                                 "shuffle" - Valid only for "blosc"
%                                             compression.
%                                             Method for rearranging input
%                                             data for blosc compression,
%                                             specified as one of these
%                                             values:
%                                                -1 - Automatic shuffle.
%                                                The function performs a
%                                                bit-wise shuffle
%                                                     if the element size
%                                                     is one byte and
%                                                     otherwise performs a
%                                                     byte-wise shuffle.
%                                                 0 - No shuffle. 1 -
%                                                 Byte-wise shuffle. 2 -
%                                                 Bit-wise shuffle.
%                                             The default value is 0.
%                                 "blocksize" - Valid only for "blosc"
%                                               compression.
%                                               Block size for blosc
%                                               compression, specified as a
%                                               nonnegative integer or inf.
%                                               The default value is 0.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonempty}
    datashape (1,:) double {mustBeFinite, mustBeNonnegative}
    options.ChunkSize (1,:) double {mustBeFinite, mustBeNonnegative} = datashape
    options.Datatype {mustBeTextScalar, mustBeNonempty} = 'double'
    options.FillValue {mustBeNumeric} = []
    options.Compression {mustBeStructOrEmpty} = []
end

zarrObj = Zarr(filepath);

% Dimensionality of the dataset and the chunk size must be the same
if any(size(datashape) ~= size(options.ChunkSize))
    error("Chunk size and the dataset must have the same number of dimensions.");
end

if any(options.ChunkSize > datashape)
    error("Chunk size cannot be greater than size of the data to be written.");
end
if isscalar(datashape)
    datashape = [1 datashape];
    options.ChunkSize = [1 options.ChunkSize];
end

zarrObj.create(options.Datatype, datashape, options.ChunkSize, options.FillValue, options.Compression)

end

% Input validation for compresion
function mustBeStructOrEmpty(compression)
if ~(isstruct(compression) || isempty(compression))
    error("Compression must be a struct or empty.");
end
end