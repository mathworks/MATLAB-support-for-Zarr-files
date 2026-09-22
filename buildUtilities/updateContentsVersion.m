function updateContentsVersion(contentsPath, version, release)
%UPDATECONTENTSVERSION Refresh the Version line in a Contents.m file.
%   UPDATECONTENTSVERSION(CONTENTSPATH, VERSION, RELEASE) rewrites the
%   "% Version <version> (<release>) <date>" line that ver() reads, stamping
%   it with today's date. VERSION and RELEASE come from the build so the
%   line never drifts from the packaged toolbox.

% Copyright 2026 The MathWorks, Inc.

    arguments
        contentsPath (1,1) string
        version (1,1) string
        release (1,1) string
    end

    lines = readlines(contentsPath);
    idx = find(startsWith(strip(lines), "% Version"), 1);
    if isempty(idx)
        error("MATLAB:Zarr:contentsVersionMissing", ...
            "No '%% Version' line found in %s.", contentsPath);
    end

    dateStr = string(datetime("today", Format="dd-MMM-yyyy"));
    lines(idx) = sprintf("%% Version %s (%s) %s", version, release, dateStr);
    writelines(lines, contentsPath);
end
