classdef tZarrRead < matlab.unittest.TestCase
    % Tests for zarrread function to read data from Zarr files in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    properties(Constant)
        % Path for read functions
        GrpPathRead = "dataFiles/grp_v2"
        ArrPathRead = "dataFiles/grp_v2/arr_v2"
        ArrPathReadSmall = "dataFiles/grp_v2/smallArr"
        ArrPathReadVector = "dataFiles/grp_v2/vectorData"
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

        function verifyPartialArrayData(testcase)
            % Verify array data using zarrread function with Start/Stride/Count.

            % The full data in the small array is
            % 
            % 1    4    7   10
            % 2    5    8   11
            % 3    6    9   12
            zpath = testcase.ArrPathReadSmall;

            % Start
            actData = zarrread(zpath, Start=[2, 3]);
            expData = [8, 11; 9, 12];
            testcase.verifyEqual(actData,expData,...
                'Failed to verify reading with Start.');

            % Count
            actData = zarrread(zpath, Count=[2, 1]);
            expData = [1;2];
            testcase.verifyEqual(actData,expData,...
                'Failed to verify reading with Count.');

            % Stride
            actData = zarrread(zpath, Stride=[3, 2]);
            expData = [1, 7];
            testcase.verifyEqual(actData,expData,...
                'Failed to verify reading with Stride.');

            % Start, Stride, and Count
            actData = zarrread(zpath,...
                Start=[2, 1], Stride=[1, 2], Count=[1,2]);
            expData = [2, 8];
            testcase.verifyEqual(actData,expData,...
                'Failed to verify reading with Start, Stride, and Count.');
        end

        function verifyPartialVectorData(testcase)
            % Verify that specifying a scalar value for Start/Stride/Count
            % for vector datasets works as expected

            zpath = testcase.ArrPathReadVector; % data is 1:10

            expData = [2,5];
            actData = zarrread(zpath, Start=2, Stride=3, Count=2);
            testcase.verifyEqual(actData,expData,...
                'Failed to verify using scalar Start, Stride, and Count.');
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

        function invalidPartialReadParams(testcase)
            % Verify zarrread errors when invalid partial read
            % Start/Stride/Count are used
            
            zpath = testcase.ArrPathReadSmall; % a 2D array, 3x4
    
            errID = 'MATLAB:Zarr:badPartialReadDimensions';
            wrongNumberOfDimensions = [1,1,1];
            testcase.verifyError(...
                @()zarrread(zpath,Start=wrongNumberOfDimensions),...
                errID);
            testcase.verifyError(...
                @()zarrread(zpath,Stride=wrongNumberOfDimensions),...
                errID);
            testcase.verifyError(...
                @()zarrread(zpath,Count=wrongNumberOfDimensions),...
                errID);

            %TODO: negative values, wrong datatypes, out of bounds
           
        end
    end
end