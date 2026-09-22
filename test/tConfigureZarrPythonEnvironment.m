classdef tConfigureZarrPythonEnvironment < SharedZarrTestSetup
    % Tests for configureZarrPythonEnvironment and the Python version guard.
    %
    % The version-guard tests are pure and run everywhere. The package tests
    % are guarded by assumptions so the normal suite (numpy/tensorstore
    % installed) runs the "present" path, while the dedicated no-dependency CI
    % job (packages absent) runs the "missing" paths.

    % Copyright 2026 The MathWorks, Inc.

    methods(Test)

        function errorsWhenNoPythonConfigured(testcase)
            % Empty pyenv version reports a configuration error.
            testcase.verifyError( ...
                @() Zarr.checkSupportedPythonVersion("", "3.10"), ...
                "MATLAB:Zarr:pythonNotConfigured");
        end

        function errorsWhenVersionTooOld(testcase)
            % A version below the minimum is rejected (3.9 < 3.10).
            testcase.verifyError( ...
                @() Zarr.checkSupportedPythonVersion("3.9", "3.10"), ...
                "MATLAB:Zarr:pythonNotConfigured");
        end

        function acceptsSupportedVersions(testcase)
            % Equal and newer versions must not error.
            Zarr.checkSupportedPythonVersion("3.10", "3.10");
            Zarr.checkSupportedPythonVersion("3.11", "3.10");
            testcase.verifyFalse(Zarr.versionIsLessThan("3.11", "3.10"));
        end

        function reportsReadyWhenPackagesPresent(testcase)
            % With packages installed, the helper reports the environment ready.
            testcase.assumeTrue(tConfigureZarrPythonEnvironment.packagesPresent(), ...
                "Requires numpy and tensorstore to be installed.");
            out = evalc("configureZarrPythonEnvironment()");
            testcase.verifySubstring(out, "ready");
        end

        function reportsMissingWhenPackagesAbsent(testcase)
            % Without packages, Install=false prints the pip command to run.
            testcase.assumeFalse(tConfigureZarrPythonEnvironment.packagesPresent(), ...
                "Requires numpy and tensorstore to be absent.");
            out = evalc("configureZarrPythonEnvironment(Install=false)");
            testcase.verifySubstring(out, "pip install");
        end

        function backendErrorsWhenPackagesAbsent(testcase)
            % Loading the Python backend without tensorstore raises the
            % actionable pythonNotConfigured error rather than a raw py. error.
            testcase.assumeFalse(tConfigureZarrPythonEnvironment.packagesPresent(), ...
                "Requires numpy and tensorstore to be absent.");
            testcase.verifyError(@() Zarr.ZarrPy(), ...
                "MATLAB:Zarr:pythonNotConfigured");
        end

    end

    methods(Static)
        function tf = packagesPresent()
            % True if both numpy and tensorstore import successfully.
            tf = true;
            for pkg = ["numpy", "tensorstore"]
                try
                    py.importlib.import_module(pkg);
                catch
                    tf = false;
                end
            end
        end
    end
end
