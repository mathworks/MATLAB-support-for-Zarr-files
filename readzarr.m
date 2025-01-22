function data = readzarr(file_path)

Zarrobj = Zarr(file_path);
data = Zarrobj.read;
end