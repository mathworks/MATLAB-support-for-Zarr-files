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
    cmd = sprintf('"%s" -m pip install -r "%s"', pythonExe, reqFile);
    status = system(cmd);
    if status ~= 0
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "pip install failed (exit code %d). Run manually:\n  %s", status, cmd);
    end

    if ~packagesImport()
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "Packages installed but still cannot be imported. A MATLAB " + ...
            "restart may be required for an in-process Python environment.");
    end
    fprintf("Zarr Python environment is ready.\n");
end
