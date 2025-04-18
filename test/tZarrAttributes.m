classdef tZarrAttributes < SharedZarrTestSetup
    % Tests for zarrwriteatt function to get attribute info of the Zarr file in MATLAB.

    % Copyright 2025 The MathWorks, Inc.

    methods(TestClassSetup)
        function createZarrArrayWithAttrs(testcase)
            % Create Zarr array and add some attributes.
            zarrcreate(testcase.ArrPathWrite,testcase.ArrSize);
            zarrwriteatt(testcase.ArrPathWrite,'attr1','This is an array attribute.');
            zarrwriteatt(testcase.ArrPathWrite,'attr2',{1,2,3});
            attr3.numVal = 10;
            attr3.strArr = ["array","attribute"];
            zarrwriteatt(testcase.ArrPathWrite,'attr3',attr3);
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
            %testcase.assumeTrue(false,'Filtered until the attributes display is fixed.');
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
            % Write attribute info using zarrwriteatt function to a group.
            testcase.assumeTrue(false,'Filtered until Issue-35 is fixed.');

            % Unable to read attribute data from a group/array created
            % using Python.
        end

        function verifyZarrV3WriteError(testcase)
            % Verify error when a user tries to write attribute to zarr v3
            % file.
            testcase.assumeTrue(false,'Filtered until the right error message is thrown.');
            filePath = 'dataFiles/grp_v3/arr_v3';
            testcase.verifyError(@()zarrwriteatt(filePath,'myAttr','attrVal'), ...
                testcase.PyException);
        end

        function nonExistentFile(testcase)
            % Verify error when using a non-existent file with zarrwriteatt 
            % function.
            testcase.verifyError(@()zarrwriteatt('testFile/nonExistentArr','myAttr','attrVal'), ...
                'MATLAB:validators:mustBeFolder');
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
            errID =  'MATLAB:validators:mustBeFolder';

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