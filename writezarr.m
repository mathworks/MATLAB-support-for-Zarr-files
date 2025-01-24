function writezarr(file_path, data)

Zarrobj = Zarr(file_path);
% data_shape = size(data);
% dtype = class(data);
Zarrobj.write(data)

% [TstoreDtype, Zarrdtype] = getLibraryDatatypes(dtype);

% py.ZarrPy.writeZarr(file_path, data_shape, chunk_shape, data, TstoreDtype, Zarrdtype);

end