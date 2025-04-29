function infoStruct = zarrinfo(filepath)
%ZARRINFO Retrieve info about the Zarr array
% %   INFO = ZARRINFO(FILEPATH) reads the metadata associated with a Zarr
% array or group located at "filepath" and return the information in a
% structure INFO, whose fields are the names of the metadata keys. 
% If "filepath" is a Zarr array (has a valid `.zarray` file), the value of
% "node_type" is "array"; if "filepath" is a Zarr group (has a valid
% `.zgroup` file), the value of the field "node_type" is "group". If you
% specify the "filepath" as a group (intermediate directory) with no
% `.zgroup` file, then the function will issue an error.

%   Copyright 2025 The MathWorks, Inc.

arguments
    filepath {mustBeTextScalar, mustBeNonzeroLengthText, mustBeFolder}
end

% .zarray and .zgroup are valid metadata files for Zarr v2 which contain
% library-defined attributes. zarr.json is valid metadata file for Zarr v3
% containing library-defined attributes.
% If the location is a Zarr array
if isfile(fullfile(filepath, '.zarray'))
    infoStr = fileread(fullfile(filepath, '.zarray'));
    infoStruct = jsondecode(infoStr);
    infoStruct.node_type = 'array';
% If the location is a Zarr group    
elseif isfile(fullfile(filepath, '.zgroup'))
    infoStr = fileread(fullfile(filepath, '.zgroup'));
    infoStruct = jsondecode(infoStr);
    infoStruct.node_type = 'group';
% Supporting zarr.json for zarr v3 (low hanging fruit for future)
elseif isfile(fullfile(filepath, 'zarr.json'))
    infoStr = fileread(fullfile(filepath, 'zarr.json'));
    infoStruct = jsondecode(infoStr);
% Else, error if it is not an array or group
else
    error("Not a valid Zarr array or group");
end

% User defined attributes are contained in .zattrs file in each array or group store
if isfile(fullfile(filepath, '.zattrs'))
    userDefinedInfoStruct = readZattrs(filepath);
    userDefinedFieldNames = fieldnames(userDefinedInfoStruct);
    for i = 1:numel(userDefinedFieldNames)
            infoStruct.(userDefinedFieldNames{i}) = userDefinedInfoStruct.(userDefinedFieldNames{i});
    end
end

end