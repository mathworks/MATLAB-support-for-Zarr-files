classdef tZarrAttributes < SharedZarrTestSetup
    % Tests for zarrwriteatt function to get attribute info of the Zarr file in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    methods(TestClassSetup)
        function createZarrArrayWithAttrs(testcase)
            % Create Zarr array and add some attributes.
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize);
            zarrwriteatt(testcase.ArrPathWrite,'scalarText','This is an array attribute.');
            zarrwriteatt(testcase.ArrPathWrite,'numericVector',[1,2,3]);
            zarrwriteatt(testcase.ArrPathWrite,'numericCellArray',{1,2,3});
            zarrwriteatt(testcase.ArrPathWrite,'mixedCellArray',{1,'two',3});
            attrStruct.numVal = 10;
            attrStruct.strArr = ["array","attribute"];
            zarrwriteatt(testcase.ArrPathWrite,'struct',attrStruct);
        end
    end

    methods(Test)
        function verifyArrayAttributeInfo(testcase)
            % Write attribute info using zarrwriteatt function to an array
            % (during test setup) and verify written values using zarrinfo

            actInfo = zarrinfo(testcase.ArrPathWrite);

            testcase.verifyEqual(actInfo.scalarText,...
                'This is an array attribute.',...
                'Failed to verify attribute info for scalar text.');
            testcase.verifyEqual(actInfo.numericVector,...
                [1;2;3],... % JSON stores all vectors as column vectors
                'Failed to verify attribute info for numeric vector.');
            testcase.verifyEqual(actInfo.numericCellArray,...
                [1;2;3],... % JSON stores numeric cell array as column vector
                'Failed to verify attribute info for numeric cell array.');
            testcase.verifyEqual(actInfo.mixedCellArray,...
                {1; 'two'; 3},...% JSON stores all vectors as column vectors
                'Failed to verify attribute info for mixed cell array.');

            expStruct.numVal = 10;
            % JSON stores string arrays as column cell arrays of char
            % vectors
            expStruct.strArr = {'array';'attribute'}; 
            testcase.verifyEqual(actInfo.struct,...
                expStruct,...
                'Failed to verify attribute info for struct.');
        end

        function verifyAttrOverwrite(testcase)
            % Verify attribute value after overwrite.
            
            expAttrStr = 'New attribute value';
            zarrwriteatt(testcase.ArrPathWrite,'scalarText',expAttrStr);
            expAttrDbl = 10;
            zarrwriteatt(testcase.ArrPathWrite,'numericVector',expAttrDbl);

            arrInfo = zarrinfo(testcase.ArrPathWrite);

            actAttrStr = arrInfo.scalarText;
            actAttrDbl = arrInfo.numericVector;

            testcase.verifyEqual(actAttrStr,expAttrStr,...
                'Failed to verify string attribute info');
            testcase.verifyEqual(actAttrDbl,expAttrDbl,...
                'Failed to verify double attribute info');
        end

        function verifyGroupAttributeInfo(testcase)
            % Write attribute info using zarrwriteatt function to a group.
            testcase.assumeTrue(false,'Filtered until Issue-35 is fixed.');

            % Unable to read attribute data from a group/array created
            % using Python.
        end

        function verifyZarrV3WriteError(testcase)
            % Verify error when a user tries to write attribute to zarr v3 file.
            filePath = 'grp_v3/arr_v3';
            errID = 'MATLAB:zarrwriteatt:writeAttV3';
            testcase.verifyError(@()zarrwriteatt(filePath,'myAttr','attrVal'),errID);
        end

        function nonExistentFile(testcase)
            % Verify error when using a non-existent file with zarrwriteatt 
            % function.
            testcase.verifyError(@()zarrwriteatt('testFile/nonExistentArr','myAttr','attrVal'), ...
                'MATLAB:zarrwriteatt:invalidZarrObject');
        end

        function notZarrObject(testcase)
            % Verify error when a user tries to write attributes to an
            % invalid Zarr object.
            errID = 'MATLAB:zarrwriteatt:invalidZarrObject';
            folderPath = fullfile('my_grp','my_arr');
            mkdir(folderPath);
            testcase.verifyError(@()zarrwriteatt(folderPath,'myAttr','attrVal'), ...
                errID);
        end

        function noWritePermissions(testcase)
            % Verify error if there are no write permissions to the Zarr array.
            
            % Make the folder read-only.
            fileattrib(testcase.ArrPathWrite,'-w','','s');
            testcase.addTeardown(@()fileattrib(testcase.ArrPathWrite,'+w','','s'));

            errID = 'MATLAB:zarrwriteatt:fileOpenFailure';
            testcase.verifyError(@()zarrwriteatt(testcase.ArrPathWrite,'myAttr','attrVal'), ...
                errID);
        end

        function tooManyInputs(testcase)
            % Verify error when too many inputs are used with zarrwrite
            % function.
            testcase.verifyError(@()zarrwriteatt(testcase.ArrPathWrite,'myAttr','attrVal','extra'), ...
                'MATLAB:TooManyInputs');
        end

        function tooFewInputs(testcase)
            % Verify error when too few inputs with zarrwriteatt function 
            % are used.
            testcase.verifyError(@()zarrwriteatt(testcase.ArrPathWrite,'myAttr'), ...
                'MATLAB:minrhs');
        end

        function invalidInput(testcase)
            % Verify error when invalid input is used for zarrwriteatt
            % function.
            errID =  'MATLAB:zarrwriteatt:invalidZarrObject';

            % Invalid file path type
            testcase.verifyError(@()zarrwriteatt('nonexistent','myAttr',10),errID);
            
            % Invalid attribute name
            errID = 'MATLAB:validators:mustBeNonzeroLengthText';
            testcase.verifyError(@()zarrwriteatt(testcase.ArrPathWrite,'',10),errID);
            errID = 'MATLAB:validators:mustBeTextScalar';
            testcase.verifyError(@()zarrwriteatt(testcase.ArrPathWrite,10,10),errID);
        end
    end
end