function files = projectMatlabFiles()
    %PROJECTMATLABFILES List all .m files in the project.
    %   Returns a string column vector of absolute paths covering toolbox/,
    %   test/, buildUtilities/, and root-level .m files (e.g. buildfile.m).
    d = [dir(fullfile("toolbox", "**", "*.m"));
        dir(fullfile("test", "**", "*.m"));
        dir(fullfile("buildUtilities", "**", "*.m"));
        dir("*.m")];
    files = string(fullfile({d.folder}, {d.name}))';
end

% Copyright 2026 The MathWorks, Inc.
