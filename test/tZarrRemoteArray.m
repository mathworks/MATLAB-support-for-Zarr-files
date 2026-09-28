classdef tZarrRemoteArray < SharedZarrTestSetup
    % TZARRREMOTEARRAY Tests for creating and reading Zarr arrays 
    % to/from remote location, using mocks.

    % Copyright 2026 The MathWorks, Inc.

    properties
        ZarrDataFolder
    end

    methods(TestClassSetup)
        function injectMocks(testCase)
            % Add mocks to path
            % ZarrPy.py needs to be on Python's module search path.
            % Other MATLAB mocks need to be on MATLAB search path.
            import matlab.unittest.fixtures.PathFixture

            mockPath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'tools', 'mocks');
            testCase.applyFixture(PathFixture(mockPath));

            % Insert mock ZarrPy ahead of real one on py.sys.path
            insert(py.sys.path, int32(0), mockPath);
            py.importlib.invalidate_caches();
            py.importlib.reload(py.importlib.import_module('ZarrPy'));
            testCase.addTeardown(@()py.importlib.import_module('ZarrPy').cleanDataRoot());
            testCase.ZarrDataFolder = string(py.importlib.import_module('ZarrPy').getDataRoot());

            % Restore real Python module on teardown
            testCase.addTeardown(@() testCase.restoreRealZarrPyModule(mockPath));
        end
    end
    
    methods(Test)
        function roundTripDefaultSyntax(testCase)
            % Create via S3 with default options, write data, read back
            s3Path = 's3://mockbucket/testgrp/arr_default';
            arrSize = testCase.ArrSize;
            zarrcreate(s3Path, arrSize);

            localPath = testCase.getLocalPath(s3Path);
            expData = rand(arrSize);
            zarrwrite(localPath, expData);
            actData = zarrread(localPath);
            testCase.verifyEqual(actData, expData);
        end

        function roundTripUserDefinedSyntax(testCase)
            % Create via S3 with user-defined options, write data, read
            % back. Option-handling code is identical for local and
            % cloud — exhaustive coverage is in tZarrCreate/tZarrWrite.
            s3Path = 's3://mockbucket/testgrp/arr_userdefined';
            comp.id = 'blosc';
            comp.clevel = 5;
            comp.shuffle = -1;

            zarrcreate(s3Path, testCase.ArrSize, ChunkSize=testCase.ChunkSize, ...
                Datatype='double', FillValue=-9, Compression=comp);

            localPath = testCase.getLocalPath(s3Path);
            expData = rand(testCase.ArrSize);
            zarrwrite(localPath, expData);
            actData = zarrread(localPath);
            testCase.verifyEqual(actData, expData);
        end
    end

    methods
        function localPath = getLocalPath(testCase,s3URL)
            % Generate local folder path equivalent using mocks, for the s3
            % path input provided by the user.
            [bucket, objPath] = Zarr.extractS3BucketNameAndPath(s3URL);
            localPath = fullfile(testCase.ZarrDataFolder, bucket, objPath);
        end

        function restoreRealZarrPyModule(~,mockPath)
            % Revert mock path addition and add real ZarrPy module again, on
            % teardown.
            py.sys.path().remove(mockPath);
            py.importlib.invalidate_caches();
            py.importlib.reload(py.importlib.import_module('ZarrPy'));
        end
    end
end