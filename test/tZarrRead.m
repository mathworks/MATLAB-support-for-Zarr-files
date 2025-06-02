classdef tZarrRead < matlab.unittest.TestCase
    % Tests for zarrread function to read data from Zarr files in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    properties(Constant)
        % Path for read functions
        GrpPathRead = "dataFiles/grp_v2"
        ArrPathRead = "dataFiles/grp_v2/arr_v2"
        ArrPathReadV3 = "dataFiles/grp_v3/arr_v3"

        ExpData = load(fullfile(pwd,"dataFiles","expZarrArrData.mat"))
    end

    methods(TestClassSetup)
        function addSrcCodePath(testcase)
            % Add source code path before running the tests
            import matlab.unittest.fixtures.PathFixture
            testcase.applyFixture(PathFixture(fullfile('..'),'IncludeSubfolders',true))
        end
    end

    methods(Test)
        function verifyArrayData(testcase)
            % Verify array data using zarrread function.
            actArrData = zarrread(testcase.ArrPathRead);
            expArrData = testcase.ExpData.arr_v2;
            testcase.verifyEqual(actArrData,expArrData,'Failed to verify array data.');
        end

        function verifyArrayDataRelativePath(testcase)
            % Verify array data if the input is using relative path to the
            % array.
            inpPath = fullfile('..','test',testcase.ArrPathRead);
            actArrData = zarrread(inpPath);
            expArrData = testcase.ExpData.arr_v2;
            testcase.verifyEqual(actArrData,expArrData,['Failed to verify array ' ...
                'data with relative path.']);
        end

        function verifyGroupInpError(testcase)
            % Verify error if a user tries to pass the group as input to
            % zarrread function.
            errID = 'MATLAB:Zarr:invalidZarrObject';
            testcase.verifyError(@()zarrread(testcase.GrpPathRead),errID);
        end

        function verifyArrReadV3(testcase)
            % Verify error when a user tries to read a zarr format v3
            % array.
            errID = 'MATLAB:Zarr:invalidZarrObject';
            testcase.verifyError(@()zarrread(testcase.ArrPathReadV3),errID);
        end

        function nonExistentArray(testcase)
            % Verify zarrread error when a user tries to read a non-existent
            % file.
            errID = 'MATLAB:Zarr:invalidZarrObject';
            testcase.verifyError(@()zarrread('nonexistent/'),errID);
        end

        function invalidFilePath(testcase)
            % Verify zarrread error when an invalid file path is used.

            % Using a cell input with a valid array path
            errID = 'MATLAB:validators:mustBeTextScalar';
            testcase.verifyError(@()zarrread({testcase.ArrPathRead}),errID);

            % Empty cell or double
            testcase.verifyError(@()zarrread({}),errID);
            testcase.verifyError(@()zarrread([]),errID);

            % Non-scalar input
            testcase.verifyError(@()zarrread([testcase.ArrPathRead,testcase.ArrPathRead]), ...
                errID);

            % Empty char
            errID = 'MATLAB:validators:mustBeNonzeroLengthText';
            testcase.verifyError(@()zarrread(''),errID);

            % Non-existent bucket
            inpPath = 's3://invalid/bucket/path';
            errID = 'MATLAB:Zarr:invalidZarrObject';
            testcase.verifyError(@()zarrread(inpPath),errID);
        end
    end
end