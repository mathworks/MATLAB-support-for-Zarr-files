function writezarr(file_path, chunk_shape, data)

Zarrobj = Zarr(file_path);
data_shape = size(data);
dtype = class(data);
Zarrobj.write(file_path, dtype, data_shape, chunk_shape, data)

% [TstoreDtype, Zarrdtype] = getLibraryDatatypes(dtype);

% py.ZarrPy.writeZarr(file_path, data_shape, chunk_shape, data, TstoreDtype, Zarrdtype);

end