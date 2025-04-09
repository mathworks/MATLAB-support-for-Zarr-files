function zarrwriteatt(filepath, attname, attvalue)
%ZARRWRITEATT Write custom Zarr attributes
%   ZARRWRITEATT(FILEPATH,ATTNAME,ATTVALUE) writes the attribute named
%   ATTNAME with the value ATTVALUE to the Zarr array or group located at
%   FILE_PATH. The attribute is recorded only if a .zarray or .zgroup file
%   already exists at the location specified by FILEPATH.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
    attname {mustBeTextScalar, mustBeNonzeroLengthText}
    attvalue
end

info = zarrinfo(filepath);
info.(attname) = attvalue;

switch (info.node_type)
    case "array"
        jsonfilename = fullfile(filepath, '.zarray');
    case "group"
        jsonfilename = fullfile(filepath, '.zgroup');
end

% 'node_type' was synthetically added by zarrinfo. So,
% remove it from the info struct before writing it back to the
% JSON file.
info = rmfield(info, 'node_type');

% Encode the updated structure back to JSON
updatedJsonStr = jsonencode(info);

% Write the updated JSON data back to the file
fid = fopen(jsonfilename, 'w');
if fid == -1
    error(['Could not open file ''' filepath ''' for writing.']);
end
fwrite(fid, updatedJsonStr, 'char');
fclose(fid);

end