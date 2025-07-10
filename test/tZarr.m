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

            Zarr.pyReloadInProcess();
            zarrPyModule = Zarr.ZarrPy;
            testcase.verifyTrue(isa(zarrPyModule, 'py.module'))

        end

  
    end
end