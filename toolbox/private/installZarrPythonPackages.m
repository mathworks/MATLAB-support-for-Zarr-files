function installZarrPythonPackages(pythonExe, reqFile)
%INSTALLZARRPYTHONPACKAGES pip install the Zarr Python requirements.
%   Shells out to the configured Python interpreter to install the packages
%   listed in reqFile, then verifies they import.
%
%   This side-effecting path is intentionally not exercised by automated
%   tests -- running it would mutate the CI Python environment -- so it is
%   excluded from coverage via codecov.yml.

%   Copyright 2026 The MathWorks, Inc.

    arguments
        pythonExe (1,1) string
        reqFile (1,1) string
    end

    fprintf("Installing required Python packages into %s ...\n", pythonExe);
    cmd = pipInstallCommand(pythonExe, reqFile);
    % "-echo" streams pip's output live and still captures it in cmdout, which
    % system() otherwise suppresses when a second output is requested.
    [status, cmdout] = system(cmd, "-echo");
    if status ~= 0
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "pip install failed (exit code %d):\n%s\nRun manually:\n  %s", ...
            status, cmdout, cmd);
    end

    if ~packagesImport()
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "Packages installed but still cannot be imported. A MATLAB " + ...
            "restart may be required for an in-process Python environment.");
    end
    fprintf("Zarr Python environment is ready.\n");
end
