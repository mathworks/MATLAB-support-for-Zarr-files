function zarrcreate(file_path, data_shape, varargin)
%ZARRCREATE Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
addParameter(p, 'ChunkSize', data_shape, ...
    @(x) validateattributes(x,{'double'},{'row','finite','nonnegative'},'','CHUNKSIZE'));

addParameter(p, 'Datatype', 'double', ...
    @(x) validateattributes(x,{'char', 'string'},{'nonempty', 'scalartext'},'','DATATYPE'));

addParameter(p, 'FillValue', 'null', ...
    @(x) validateattributes(x,{'numeric', 'char', 'string'},{'scalar', 'scalartext'},'','FILLVALUE'));

comp = [];
addParameter(p, 'Compression', comp);

p.parse(varargin{:});
Zarrobj = Zarr(file_path);

dtype = p.Results.Datatype;
chunk_shape = p.Results.ChunkSize;
compression = p.Results.Compression;

Zarrobj.create(dtype, data_shape, chunk_shape, compression)


end