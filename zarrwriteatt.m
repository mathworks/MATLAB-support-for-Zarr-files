function zarrwriteatt(filepath, attname, attvalue)
%ZARRWRITEATT Write custom Zarr attributes
%   ZARRWRITEATT(FILEPATH,ATTNAME,ATTVALUE) writes the attribute named
%   ATTNAME with the value ATTVALUE to the Zarr array or group located at
%   FILEPATH. The attribute is recorded only if a .zarray or .zgroup file
%   already exists at the location specified by FILEPATH.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
    attname {mustBeTextScalar, mustBeNonzeroLengthText}
    attvalue
end

if isfile(fullfile(filepath,'zarr.json'))
    error("Writing attributes to Zarr v3 files is not supported.");
end

if (~isfile(fullfile(filepath,'.zgroup')) && ~isfile(fullfile(filepath,'.zarray')))
    error("Not a valid Zarr group or array.");
end

attrsJSONFile = fullfile(filepath, '.zattrs');
% If .zattrs file exists already, append to it. If not, create the file and
% write to it.
if isfile(attrsJSONFile)
    userDefinedInfoStruct = readZattrs(filepath);
else
    userDefinedInfoStruct = struct();
end
userDefinedInfoStruct.(attname) = attvalue;

% Encode the updated structure back to JSON
updatedJsonStr = jsonencode(userDefinedInfoStruct);

% Write the updated JSON data back to the file
fid = fopen(attrsJSONFile, 'w');
if fid == -1
    error(['Could not open file ''' filepath ''' for writing.']);
end
fwrite(fid, updatedJsonStr, 'char');
fclose(fid);

end