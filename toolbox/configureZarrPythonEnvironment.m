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

%   Copyright 2025 The MathWorks, Inc.

    arguments
        options.Install (1,1) logical = true
    end

    minVersion = "3.10";

    pe = pyenv;
    if pe.Version == ""
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "No Python environment is configured for MATLAB. Install " + ...
            "Python %s or newer and point MATLAB at it with pyenv. See " + ...
            "https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html", ...
            minVersion);
    end

    if pe.Version < minVersion
        error("MATLAB:Zarr:pythonNotConfigured", ...
            "Python %s is configured, but %s or newer is required.", ...
            pe.Version, minVersion);
    end

    if packagesImport()
        fprintf("Zarr Python environment is ready (Python %s, %s).\n", ...
            pe.Version, pe.Executable);
        return
    end

    reqFile = fullfile(fileparts(mfilename("fullpath")), ...
        "PythonModule", "requirements.txt");

    if ~options.Install
        fprintf("Required Python packages are missing. Install them with:\n\n" + ...
            "  ""%s"" -m pip install -r ""%s""\n\n", pe.Executable, reqFile);
        return
    end

    fprintf("Installing required Python packages into %s ...\n", pe.Executable);
    cmd = sprintf('"%s" -m pip install -r "%s"', pe.Executable, reqFile);
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

function ok = packagesImport()
    % True if both numpy and tensorstore import successfully.
    ok = true;
    for pkg = ["numpy", "tensorstore"]
        try
            py.importlib.import_module(pkg);
        catch
            ok = false;
        end
    end
end
