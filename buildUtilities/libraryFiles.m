function files = libraryFiles()
    %LIBRARYFILES List the toolbox library .m files.
    %   Returns a string column vector of absolute paths. Used by the test task
    %   for coverage measurement and by the lint tasks for static analysis scope.
    fs = matlab.io.datastore.FileSet("toolbox", ...
        FileExtensions=".m", IncludeSubfolders=true);
    files = fs.FileInfo.Filename;
end
