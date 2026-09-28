function status = isfolder(path)
% Mock function for built-in ISFOLDER function.

% Copyright 2026 The MathWorks, Inc.

if startsWith(path, "s3://") || startsWith(path, "https://")
    status = true;
else
    status = exist(path, 'dir') == 7;
end
end