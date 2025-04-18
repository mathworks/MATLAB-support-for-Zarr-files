classdef SharedZarrTestSetup < matlab.unittest.TestCase
    % Shared test set up for Zarr tests.

    % Copyright 2025 The MathWorks, Inc.

    properties
        PyException = "MATLAB:Python:PyException"
        ArrSize = [20 25]
        ChunkSize = [4 5]

        % Path for write tests
        ArrPathWrite = "prt_grp_write/arr1"
    end

    methods(TestClassSetup)
	function addSrcCodePath(testcase)
	    % Add source code path before running the tests
            import matlab.unittest.fixtures.PathFixture
	    testcase.applyFixture(PathFixture(fullfile('..'),'IncludeSubfolders',true))
	end

        function setupWorkingFolderToCreateArr(testcase)
            % Use working folder fixture to create Zarr array.
            import matlab.unittest.fixtures.WorkingFolderFixture;
            testcase.applyFixture(WorkingFolderFixture);
        end
    end
end