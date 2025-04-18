function zattrsStruct = readZattrs(filepath)
%READZATTRS Helper function to read the JSON file .zattrs which contains
%user defined attributes for a Zarr array or group.

%   Copyright 2025 The MathWorks, Inc.

userDefinedInfoStr = fileread(fullfile(filepath, '.zattrs'));
zattrsStruct = struct();

% If .zattrs file exists and is not empty
if ~isempty(userDefinedInfoStr)
    zattrsStruct = jsondecode(userDefinedInfoStr);
end
end