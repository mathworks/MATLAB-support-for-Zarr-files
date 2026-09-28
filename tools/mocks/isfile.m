function status = isfile(path)
% Mock function for built-in ISFILE function.

% Copyright 2026 The MathWorks, Inc.

if startsWith(path, "s3://") || startsWith(path, "https://")
    status = true;
else
    status = exist(path, 'file') == 2;
end
end