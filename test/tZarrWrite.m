classdef tZarrWrite < SharedZarrTestSetup
    % Tests for zarrwrite function to write data to Zarr files in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    properties(TestParameter)
        DataType = {'double','single','int8','uint8','int16','uint16', ...
            'int32','uint32','int64','uint64','logical'}
        CompId = {'zlib','gzip','bz2','zstd'}
        ArrSizeWrite = {[1 10],[20 25],[10 12 5]}
    end

    methods(Test)
        function createArrayLocalDefaultSyntax(testcase,ArrSizeWrite)
            % Verify the data when creating and writing to arrays of different 
            % dimensions using zarrcreate and zarrwrite locally. The default 
            % datatype is double.;
            zarrcreate(testcase.ArrPathWrite,ArrSizeWrite);
            expData = rand(ArrSizeWrite);
            zarrwrite(testcase.ArrPathWrite,expData);

            actData = zarrread(testcase.ArrPathWrite);
            testcase.verifyEqual(actData,expData,'Failed to verify array data');
        end

        function createArrayRemoteDefaultSyntax(testcase)
            % Verify data when creating and writing to arrays of different 
            % dimensions using zarrcreate and zarrwrite to a remote location.
            
            % Move to a separate file
        end

        function createArrayLocalUserDefinedSyntax(testcase,DataType,CompId)
            % Verify the data when creating and writing to arrays with 
            % user-defined properties using zarrcreate and zarrwrite locally.
            comp.level = 5;
            fillValue = -9;
            expData = cast(ones(testcase.ArrSize),DataType);
            comp.id = CompId;
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize,'ChunkSize',testcase.ChunkSize, ...
                'Compression',comp,'FillValue',fillValue,'Datatype',DataType);
            zarrwrite(testcase.ArrPathWrite,expData);

            actData = zarrread(testcase.ArrPathWrite);
            testcase.verifyEqual(actData,expData,['Failed to verify data for ' DataType ' datatype' ...
                ' with ' CompId ' compression.']);
        end

        function createArrayRemoteUserDefinedSyntax(testcase)
            % Verify data when creating and writing data to arrays with 
            % user-defined properties using zarrcreate and zarrwrite to a 
            % remote location.
        
            % Move to a separate file
        end

        function createArrayWithBlosc(testcase)
            % Verify data when creating and writing to a Zarr array using 
            % blosc compression.
            comp.id = 'blosc';
            comp.clevel = 5;
            cname = {'blosclz','lz4','lz4hc','zlib','zstd','snappy'};
            comp.shuffle = -1;
            expData = randn(testcase.ArrSize);

            for i = 1:length(cname)
                comp.cname = cname{i};
                zarrcreate(testcase.ArrPathWrite,testcase.ArrSize,'ChunkSize', ...
                    testcase.ChunkSize,'Compression',comp);
                zarrwrite(testcase.ArrPathWrite,expData);

                actData = zarrread(testcase.ArrPathWrite);
                testcase.verifyEqual(actData,expData,['Failed to verify data for ' cname(i)]);
            end
        end

        function tooFewInputs(testcase)
            % Verify error when too few inputs to zarrwrite are passed.
            errID = 'MATLAB:minrhs';
            testcase.verifyError(@()zarrwrite(testcase.ArrPathWrite),errID);
        end

        function invalidFilePath(testcase)
            % Verify error when an invalid file path is used.
            errID = 'MATLAB:validators:mustBeNonzeroLengthText';
            data = ones(10,10);
            testcase.verifyError(@()zarrwrite('',data),errID);
        end

        function dataDatatypeMismatch(testcase)
            % Verify error for mismatch between datatype value and datatype 
            % of data to be written with zarrwrite.
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize,"Datatype",'int8');
            data = ones(testcase.ArrSize);
            testcase.verifyError(@()zarrwrite(testcase.ArrPathWrite,data),testcase.PyException);
        end

        function dataDimensionMismatch(testcase)
            % Verify error when there is a dimension mismatch at the time of 
            % writing to the array.
            testcase.assumeTrue(false,'Filtered until error ID is added.');
            errID = '';
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize);
            data = ones(30,30);
            testcase.verifyError(@()zarrwrite(testcase.ArrPathWrite,data),errID);
        end

        function overwriteArray(testcase)
            % Verify data after the array data is overwritten with new
            % data.
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize, ...
                'ChunkSize',testcase.ChunkSize);
            data = ones(testcase.ArrSize);
            zarrwrite(testcase.ArrPathWrite,data);

            % Create new data
            expData = rand(testcase.ArrSize);
            zarrwrite(testcase.ArrPathWrite,expData);
            actData = zarrread(testcase.ArrPathWrite);
            testcase.verifyEqual(actData,expData,'Failed to verify array data')
        end
    end
end