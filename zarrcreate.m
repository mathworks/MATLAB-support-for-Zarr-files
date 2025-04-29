function zarrcreate(filepath, datashape, options)
%ZARRCREATE Create Zarr array.
%   ZARRCREATE(FILEPATH, DATASHAPE, Param1, Value1, ...) creates a Zarr
%   array at the path specified by FILEPATH and of the dimensions specified
%   by DATASHAPE. If FILEPATH is a full path name, all
%   intermediate groups are created if they don't already exist.
%   If FILEPATH exists already, the contents are overwritten.
%
%   Parameter Value Pairs
%   ---------------------
%       'Datatype'               - May be one of 'double', 'single', 'uint64',
%                                  'int64', 'uint32', 'int32', 'uint16', 'int16',  
%                                  'uint8', 'int8', or 'string'. Defaults to 'double'.
%       'ChunkSize'              - Defines chunking layout. Default is not chunked.
%       'FillValue'              - Defines the fill value for numeric arrays.
%                                  The default is no fill value, specified
%                                  as [].
%       'Compression'            - Primary compression codec used to
%                                  compress the Zarr array. The compression
%                                  needs to provided as a struct, with 'id'
%                                  being a required field. The required and
%                                  optional fields for compression struct
%                                  are as follows:
%                                  Required Fields:
%                                    'id'    - The accepted values are 'zlib', 'gzip', 
%                                              'blosc', 'bz2', 'zstd' or '[]' (default)
%                                               for no compression.
%                                  Optional Fields:
%                                    'level' - The compression level to
%                                              use. Valid for all but
%                                              'null' and 'blosc'.
%                                              compression. The default
%                                              value is 1. The accepted
%                                              integer values for different
%                                              compressions are:
%                                              zlib - [0, 9]
%                                              gzip - [0, 9]
%                                              bz2  - [1, 9]
%                                              zstd - [-131072, 22]
%                                    'cname' - Valid only for 'blosc'
%                                              compression. Specifies the compression
%                                              method used by 'blosc'. Accepted
%                                              values are: 
%                                             {'blosclz' | 'lz4' | 'lz4hc' | 'snappy' | 'zlib' | 'zstd' = 'lz4
%                                    'clevel' - Valid only for 'blosc'
%                                               compression. Specifies the blosc
%                                               compression level to use. Accepted
%                                               values are integers in the range 
%                                               [0, 9]. The default is 5.
%                                    'shuffle' - Valid only for 'blosc'
%                                                Options for rearranging of
%                                                the input data. The
%                                                accepted integer values are:
%                                                -1 - Automatic shuffle. Bit-wise shuffle if the element size is 1 byte, otherwise byte-wise shuffle.
%                                                 0 - No shuffle
%                                                 1 - Byte-wise shuffle
%                                                 2 - Bit-wise shuffle
%                                    'blocksize' - Valid only for 'blosc'
%                                                  Specifies the blosc
%                                                  blocksize. Accepted
%                                                  values are integer in
%                                                  the range [0 inf]. The
%                                                  default value is 0.

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