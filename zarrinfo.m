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
    filepath {mustBeTextScalar, mustBeNonzeroLengthText}
end

% .zarray and .zgroup are valid metadata files for Zarr v2 which contain
% library-defined attributes.
try
    infoStr = fileread(fullfile(filepath, '.zarray'));
    nodeType = 'array';
catch 
    try
        infoStr = fileread(fullfile(filepath, '.zgroup'));
        nodeType = 'group';
    catch ME
        % If either the .zarray or .zgroup file exists
        if any(isfile({fullfile(filepath, '.zarray'), fullfile(filepath, '.zgroup')}))
            throw(ME);    
        else
            error("MATLAB:zarrinfo:invalidZarrObject",...
                "Invalid file path. File path must refer to a valid Zarr array or group.");
        end
    end
end
infoStruct = jsondecode(infoStr);
infoStruct.node_type = nodeType;

% User defined attributes are contained in .zattrs file in each array or group store
try
    userDefinedInfoStruct = readZattrs(filepath);
    userDefinedFieldNames = fieldnames(userDefinedInfoStruct);
    for i = 1:numel(userDefinedFieldNames)
        infoStruct.(userDefinedFieldNames{i}) = userDefinedInfoStruct.(userDefinedFieldNames{i});
    end
catch
   % do nothing since the existence of .zattrs file is optional. 
end
end