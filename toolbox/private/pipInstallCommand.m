function cmd = pipInstallCommand(pythonExe, reqFile)
%PIPINSTALLCOMMAND Build the pip command that installs the Zarr requirements.
%   Single source of truth for the install command, shared by
%   configureZarrPythonEnvironment (which prints it) and
%   installZarrPythonPackages (which runs it).

%   Copyright 2026 The MathWorks, Inc.

    arguments
        pythonExe (1,1) string
        reqFile (1,1) string
    end
    cmd = sprintf('"%s" -m pip install -r "%s"', pythonExe, reqFile);
end
