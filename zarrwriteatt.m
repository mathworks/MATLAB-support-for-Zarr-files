function zarrwriteatt(file_path, attname, attvalue)
%ZARRWRITEATT Write custom Zarr attributes
%   ZARRWRITEATT(FILE_PATH,ATTNAME,ATTVALUE) writes the attribute named
%   ATTNAME with the value ATTVALUE to the Zarr array or group located at
%   FILE_PATH. The attribute is recorded only if a .zarray or .zgroup file
%   already exists at the location specified by FILE_PATH.

%   Copyright 2025 The MathWorks, Inc.

arguments
    file_path {mustBeTextScalar, mustBeNonzeroLengthText}
    attname {mustBeTextScalar, mustBeNonzeroLengthText}
    attvalue
end

Zarrobj = Zarr(file_path);
Zarrobj.writeatt(attname, attvalue);

end