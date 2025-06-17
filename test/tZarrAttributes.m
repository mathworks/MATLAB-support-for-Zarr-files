classdef tZarrAttributes < SharedZarrTestSetup
    % Tests for zarrwriteatt function to get attribute info of the Zarr file in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    methods(TestClassSetup)
        function createZarrArrayWithAttrs(testcase)
            % Create Zarr array and add some attributes.
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize);
            
            % Write array attributes
            zarrwriteatt(testcase.ArrPathWrite,'attr1','This is an array attribute.');
            zarrwriteatt(testcase.ArrPathWrite,'attr2',{1,2,3});
            attr3.numVal = 10;
            attr3.strArr = ["array","attribute"];
            zarrwriteatt(testcase.ArrPathWrite,'attr3',attr3);

            % Write group attributes
            zarrwriteatt(testcase.GrpPathWrite,'grp_description','This is a group');
            zarrwriteatt(testcase.GrpPathWrite,'grp_level',1);
        end
    end

    methods(Test)
        function verifyArrayAttributeInfo(testcase)
            % Write attribute info using zarrwriteatt function to an array.

            arrInfo = zarrinfo(testcase.ArrPathWrite);
            actAttr.attr1 = arrInfo.attr1;
            
            % TODO: Enable code once Issue-34 is fixed.
            %actAttr.attr2 = arrInfo.attr2;
            %actAttr.attr3 = arrInfo.attr3;

            expAttr.attr1 = 'This is an array attribute.';
            %expAttr.attr2 = {1,2,3};
            %expAttr.attr3.numVal = 10;
            %expAttr.attr4.strArr = ["array","attribute"];

            testcase.verifyEqual(actAttr,expAttr,'Failed to verify attribute info.');
        end

        function verifyAttrOverwrite(testcase)
            % Verify attribute value after overwrite.
            expAttrStr = ["new","attribute","value"];
            zarrwriteatt(testcase.ArrPathWrite,'attr1',expAttrStr);
            expAttrDbl = 10;
            zarrwriteatt(testcase.ArrPathWrite,'attr2',expAttrDbl);

            arrInfo = zarrinfo(testcase.ArrPathWrite);
            
            % TODO: Enable code once Issue-34 is fixed.
            %actAttrStr = arrInfo.attr1;
            actAttrDbl = arrInfo.attr2;

            %testcase.verifyEqual(actAttrStr,expAttrStr,'Failed to verify string attribute info');
            testcase.verifyEqual(actAttrDbl,expAttrDbl,'Failed to verify double attribute info');
        end

        function verifyGroupAttributeInfo(testcase)
            % Verify group attribute info.
            grpInfo = zarrinfo(testcase.GrpPathWrite);
            
            actAttr1 = grpInfo.grp_description;
            expAttr1 = 'This is a group';
            testcase.verifyEqual(actAttr1,expAttr1,'Failed to verify text attribute.');

            actAttr2 = grpInfo.grp_level;
            expAttr2 = 1;
            testcase.verifyEqual(actAttr2,expAttr2,'Failed to verify numeric attribute.');
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