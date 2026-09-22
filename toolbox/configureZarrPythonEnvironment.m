function configureZarrPythonEnvironment(options)
%CONFIGUREZARRPYTHONENVIRONMENT Verify and install the Python packages Zarr needs.
%   CONFIGUREZARRPYTHONENVIRONMENT checks that MATLAB has a supported Python
%   environment configured (via pyenv) and that the required packages
%   (numpy and tensorstore) can be imported. If they are missing it installs
%   them into the active Python environment using pip.
%
%   CONFIGUREZARRPYTHONENVIRONMENT(Install=false) only reports what is missing
%   and prints the exact pip command to run, without installing anything.
%
%   The Zarr functions delegate their I/O to the tensorstore Python library,
%   which an installed toolbox cannot provision automatically. Run this once
%   after installing the toolbox.

%   Copyright 2026 The MathWorks, Inc.

    arguments
        options.Install (1,1) logical = true
    end

    minVersion = "3.10";

    pe = pyenv;
    Zarr.checkSupportedPythonVersion(pe.Version, minVersion);

    if packagesImport()
        fprintf("Zarr Python environment is ready (Python %s, %s).\n", ...
            pe.Version, pe.Executable);
        return
    end

    reqFile = fullfile(fileparts(mfilename("fullpath")), ...
        "PythonModule", "requirements.txt");

    if ~options.Install
        cmd = pipInstallCommand(pe.Executable, reqFile);
        fprintf("Required Python packages are missing. Install them with:\n\n  %s\n\n", cmd);
        return
    end

    installZarrPythonPackages(pe.Executable, reqFile);
end
