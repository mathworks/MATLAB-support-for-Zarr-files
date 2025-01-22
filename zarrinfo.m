function info = zarrinfo(file_path)
%ZARRINFO Summary of this function goes here
%   Detailed explanation goes here
Zarrobj = Zarr(file_path);
info = Zarrobj.readinfo;
end