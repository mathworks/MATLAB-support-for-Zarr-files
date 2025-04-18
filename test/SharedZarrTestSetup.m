classdef SharedZarrTestSetup < matlab.unittest.TestCase
    % Shared test set up for Zarr tests.

    % Copyright 2025 The MathWorks, Inc.

    properties
        PyException = "MATLAB:Python:PyException"
        ArrSize = [20 25]
        ChunkSize = [4 5]

        % Path for read functions
        % GrpPathRead = "dataFiles/grp_v2"
        % ArrPathRead = "dataFiles/grp_v2/arr_v2"

        % Path for write tests
        ArrPathWrite = "prt_grp_write/arr1"
    end

    methods(TestClassSetup)
        function setupWorkingFolderToCreateArr(testcase)
            % Use working folder fixture to create Zarr array.
            import matlab.unittest.fixtures.WorkingFolderFixture;
            testcase.applyFixture(WorkingFolderFixture);
        end
    end
end