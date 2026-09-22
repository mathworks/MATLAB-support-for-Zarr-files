function ok = packagesImport()
%PACKAGESIMPORT True if both numpy and tensorstore import successfully.

%   Copyright 2026 The MathWorks, Inc.

    ok = true;
    for pkg = ["numpy", "tensorstore"]
        try
            py.importlib.import_module(pkg);
        catch
            ok = false;
        end
    end
end
