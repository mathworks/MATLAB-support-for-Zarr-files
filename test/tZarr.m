classdef tZarr < SharedZarrTestSetup
    % Tests for Zarr class methods

    % Copyright 2025 The MathWorks, Inc.

    methods(Test)

        function verifySupportedCloudPatterns(testcase)
            % Verify that the bucket name and the array path can be
            % extracted successfully if a cloud path is used as an input.
            
            % This list contains path pattern currently supported by Zarr
            % in MATLAB. Any invalid path not matching any of these
            % patterns will result in an error.
            inpPath = {'https://mybucket.s3.us-west-2.amazonaws.com/path/to/myZarrFile', ...
                    'https://mybucket.s3.amazonaws.com/path/to/myZarrFile', ...
                    'https://mybucket.s3.custom-endpoint.org/path/to/myZarrFile', ...
                    'https://s3.amazonaws.com/mybucket/path/to/myZarrFile', ...
                    'https://s3.eu-central-1.example.edu/mybucket/path/to/myZarrFile', ...
                    's3://mybucket/path/to/myZarrFile'};

            for i = 1:length(inpPath)
                [bucketName, objectPath] = Zarr.extractS3BucketNameAndPath(inpPath{i});
                testcase.verifyEqual(bucketName, 'mybucket', ['Bucket name extraction failed for ' inpPath{i}]);
                testcase.verifyEqual(objectPath, 'path/to/myZarrFile', ['Object path extraction failed for ' inpPath{i}]);
            end
        end

        function verifyReload(testcase)
            % Verify that calling reload method does not cause any issues

            Zarr.pyReloadInProcess()
            zarrPyModule = Zarr.ZarrPy;
            testcase.verifyTrue(isa(zarrPyModule, 'py.module'))

        end

        function verifyIsZarrArrayAndGroup(testcase)
            % Verify that isZarrArray and isZarrGroup correctly identify a
            % Zarr array (has .zarray) versus a Zarr group (has .zgroup).
            % SharedZarrTestSetup copies the *contents* of dataFiles into
            % the working folder, so fixtures live at grp_v2/... directly.
            arrPath = "grp_v2/arr_v2";
            grpPath = "grp_v2";

            testcase.verifyTrue(Zarr.isZarrArray(arrPath),...
                "Expected an array path to be a Zarr array.");
            testcase.verifyFalse(Zarr.isZarrArray(grpPath),...
                "Did not expect a group path to be a Zarr array.");

            testcase.verifyTrue(Zarr.isZarrGroup(grpPath),...
                "Expected a group path to be a Zarr group.");
            testcase.verifyFalse(Zarr.isZarrGroup(arrPath),...
                "Did not expect an array path to be a Zarr group.");
        end

        function verifyDatatypeRoundTrip(testcase)
            % Verify that ZarrDatatype maps consistently across MATLAB,
            % Tensorstore, and Zarr type names, regardless of which static
            % constructor is used to create it.
            mlType = "double";
            tsType = "float64";
            zType  = "<f8";

            fromML = ZarrDatatype.fromMATLABType(mlType);
            fromTS = ZarrDatatype.fromTensorstoreType(tsType);
            fromZarr = ZarrDatatype.fromZarrType(zType);

            for dt = [fromML, fromTS, fromZarr]
                testcase.verifyEqual(dt.MATLABType, mlType);
                testcase.verifyEqual(dt.TensorstoreType, tsType);
                testcase.verifyEqual(dt.ZarrType, zType);
            end
        end

        function verifyInvalidTensorstoreType(testcase)
            % Verify error when an unsupported Tensorstore type name is used.
            testcase.verifyError(...
                @()ZarrDatatype.fromTensorstoreType("not_a_type"),...
                "MATLAB:validators:mustBeMember");
        end

        function verifyCreateGroupMakesFolder(testcase)
            % Verify that createGroup creates the directory when it does not
            % already exist, and writes a valid .zgroup file into it.
            groupPath = fullfile(pwd, "brandNewGroup");
            testcase.verifyFalse(isfolder(groupPath),...
                "Group folder should not exist before createGroup.");

            Zarr.createGroup(groupPath);

            testcase.verifyTrue(isfolder(groupPath),...
                "createGroup should have created the folder.");
            testcase.verifyTrue(isfile(fullfile(groupPath, ".zgroup")),...
                "createGroup should have written a .zgroup file.");
            testcase.verifyEqual(zarrinfo(groupPath).node_type, 'group',...
                "createGroup should produce a valid Zarr group.");
        end

        function verifyCreateGroupOpenFailure(testcase)
            % Verify error when the .zgroup file cannot be opened for
            % writing. Everything lives inside an isolated temporary folder
            % fixture, so no real data is modified.
            %
            % We make the existing .zgroup *file* read-only rather than its
            % folder: a read-only folder does not prevent file creation on
            % Windows (the directory read-only attribute is ignored there),
            % whereas a read-only file is honored on both Windows and Unix.
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = testcase.applyFixture(TemporaryFolderFixture);

            groupPath = fullfile(tempFixture.Folder, "readOnlyGroup");
            Zarr.createGroup(groupPath);            % writes .zgroup
            zgroupFile = fullfile(groupPath, ".zgroup");

            fileattrib(zgroupFile, '-w');
            % Restore write permission before the fixture is torn down so its
            % contents can be removed (runs before the fixture's rmdir).
            testcase.addTeardown(@()fileattrib(zgroupFile, '+w'));

            testcase.verifyError(@()Zarr.createGroup(groupPath),...
                "MATLAB:Zarr:fileOpenFailure");
        end

        function verifyWriteScalarShapedArray(testcase)
            % Verify writing to an array whose stored shape is a true scalar
            % (shape [1]). This exercises the isscalar(info.shape) branch of
            % Zarr.write, which zarrcreate cannot produce on its own because
            % it expands scalar sizes to [1 N].
            scalarPath = "grp_v2/scalarData";

            zarrwrite(scalarPath, 42);
            testcase.verifyEqual(zarrread(scalarPath), 42,...
                "Failed to write/read a scalar-shaped Zarr array.");
        end

    end
end