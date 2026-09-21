function files = libraryFiles()
    %LIBRARYFILES List the toolbox library .m files.
    %   Returns a string column vector of absolute paths. Used by the test task
    %   for coverage measurement and by the lint tasks for static analysis scope.
    d = dir(fullfile("toolbox", "**", "*.m"));
    files = string(fullfile({d.folder}, {d.name}))';
end
