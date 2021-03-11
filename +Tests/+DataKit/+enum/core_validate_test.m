classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) core_validate_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.enum.core_validate_test);
    % run(tests)

    properties
        EnumSubclasses
        NEnumSubclasses
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        ValueShape = struct(...
            'S',        [ 1  1],...
            'H',        [ 1  5],...
            'V',        [ 5  1],...
            'W',        [ 2  5],...
            'T',        [ 5  2],...
            'M',        [ 5  5])
    end

    methods (TestClassSetup)
        function getSubclassList(testCase)
            infoDingi   = what('Dingi');
            pathDingi   = infoDingi.path;
            testCase.EnumSubclasses = getSubclasses('DataKit.enum',pathDingi);
            testCase.NEnumSubclasses = numel(testCase.EnumSubclasses);
        end
        function getSubclassMembers(testCase)
            for sc = 1:testCase.NEnumSubclasses
                [testCase.EnumSubclasses(sc).Members,testCase.EnumSubclasses(sc).MemberNames] = enumeration(testCase.EnumSubclasses(sc).Class);
            end
        end
        function getSubclassProperties(testCase)
            for sc = 1:testCase.NEnumSubclasses
                testCase.EnumSubclasses(sc).Properties = properties(testCase.EnumSubclasses(sc).Class);
                testCase.EnumSubclasses(sc).NProperties = numel(testCase.EnumSubclasses(sc).Properties);
                nProperties     = numel(testCase.EnumSubclasses(sc).Properties);
                isUnique        = false(nProperties,1);
                for pr = 1:nProperties
                    testCase.EnumSubclasses(sc).PropertyType{pr} = class(testCase.EnumSubclasses(sc).Members(1).(testCase.EnumSubclasses(sc).Properties{pr}));
                    switch testCase.EnumSubclasses(sc).PropertyType{pr}
                        case 'char'
                            propertyData    = {testCase.EnumSubclasses(sc).Members.(testCase.EnumSubclasses(sc).Properties{pr})}';
                        otherwise  
                            propertyData    = cat(1,testCase.EnumSubclasses(sc).Members.(testCase.EnumSubclasses(sc).Properties{pr}));
                    end
                    isUnique(pr)    = numel(propertyData) == numel(unique(propertyData));
                end
                testCase.EnumSubclasses(sc).PropertyIsUnique = isUnique;
            end
        end
    end
    methods (TestMethodSetup)
      
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testValidateValid(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                
                propertyIndex   = find(testCase.EnumSubclasses(cl).PropertyIsUnique,1);
                if isempty(propertyIndex)
                    return
                end
                className       = testCase.EnumSubclasses(cl).Class;
                propertyName    = testCase.EnumSubclasses(cl).Properties{propertyIndex};
                value           = testCase.EnumSubclasses(cl).Members(end).(propertyName);
                if isnumeric(value)
                    valueName   = num2str(value);
                elseif ischar(value)
                    valueName   = value;
                    value       = {value};
                end
                value           = repmat(value,ValueShape);
                
                [tf,info]       = core_validate(className,propertyName,value);
                exp             = true(ValueShape);
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,valueName,num2str(ValueShape));
                
                % Verify tf
                testCase.verifyEqual(tf,exp,diagnosticsStr)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape,diagnosticsStr)
            end
        end
        function testValidateInvalidValueType(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                
                propertyIndex   = find(testCase.EnumSubclasses(cl).PropertyIsUnique,1);
                if isempty(propertyIndex)
                    return
                end
                className       = testCase.EnumSubclasses(cl).Class;
                propertyName    = testCase.EnumSubclasses(cl).Properties{propertyIndex};
                value           = testCase.EnumSubclasses(cl).Members(end).(propertyName);
                if isnumeric(value)
                    invalidValue        = {'test'};
                    invalidValueName 	= 'test';
                else
                    invalidValue        = 3;
                    invalidValueName  	= '3';
                end
                invalidValue   	= repmat(invalidValue,ValueShape);
                
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                
                testCase.verifyError(@() ...
                    core_validate(className,propertyName,invalidValue),...
                    'Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                    diagnosticsStr)
            end
        end
        function testValidateInvalidValueAll(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                
                propertyIndex   = find(testCase.EnumSubclasses(cl).PropertyIsUnique,1);
                if isempty(propertyIndex)
                    return
                end
                className       = testCase.EnumSubclasses(cl).Class;
                propertyName    = testCase.EnumSubclasses(cl).Properties{propertyIndex};
                value           = testCase.EnumSubclasses(cl).Members(end).(propertyName);
                if isnumeric(value)
                    invalidValue        = Inf;
                    invalidValueName 	= 'Inf';
                else
                    invalidValue        = char(randi([32,126],1,30));
                    invalidValueName  	= invalidValue;
                    invalidValue        = {invalidValue};
                end                
                invalidValue   	= repmat(invalidValue,ValueShape);
                
                [tf,info]       = core_validate(className,propertyName,invalidValue);
                exp             = false(ValueShape);
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                
                % Verify tf
                testCase.verifyEqual(tf,exp,diagnosticsStr)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape,diagnosticsStr)
            end
        end
        function testValidateInvalidValueSome(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                
                propertyIndex   = find(testCase.EnumSubclasses(cl).PropertyIsUnique,1);
                if isempty(propertyIndex)
                    return
                end
                className       = testCase.EnumSubclasses(cl).Class;
                propertyName    = testCase.EnumSubclasses(cl).Properties{propertyIndex};
                value           = testCase.EnumSubclasses(cl).Members(end).(propertyName);
                
                if isnumeric(value)
                    invalidValue        = Inf;
                    invalidValueName 	= 'Inf';
                else
                    value               = {value};
                    invalidValue        = char(randi([32,126],1,30));
                    invalidValueName  	= invalidValue;
                    invalidValue        = {invalidValue};
                end
                invalidValueSome    = repmat(value,ValueShape);
                invalidValueSome(1) = invalidValue;
                
                [tf,info]       = core_validate(className,propertyName,invalidValueSome);
                exp             = true(ValueShape);
                exp(1)          = false;
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                
                % Verify tf
                testCase.verifyEqual(tf,exp,diagnosticsStr)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape,diagnosticsStr)
            end
        end
        function testValidateEnumRequest(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                import DataKit.enum.validatePropertyName
                
                className       = testCase.EnumSubclasses(cl).Class;
                classHierarchy 	= strsplit(className,'.');
                propertyName  	= [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
                propertyName  	= validatePropertyName(className,propertyName);
                nMembers        = numel(testCase.EnumSubclasses(cl).Members);
                value           = cell(ValueShape);
                value(1:prod(ValueShape))           = cellstr(testCase.EnumSubclasses(cl).Members(randi([1,nMembers],ValueShape)));
                
                [tf,info]       = core_validate(className,propertyName,value);
                exp             = true(ValueShape);
                
                % Verify tf
                testCase.verifyEqual(tf,exp)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape)
            end
        end
        function testValidateEnumRequestInvalidSome(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                import DataKit.enum.validatePropertyName
                
                className       = testCase.EnumSubclasses(cl).Class;
                classHierarchy 	= strsplit(className,'.');
                propertyName  	= [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
                propertyName  	= validatePropertyName(className,propertyName);
                nMembers        = numel(testCase.EnumSubclasses(cl).Members);
                value           = cell(ValueShape);
                value(1:prod(ValueShape))           = cellstr(testCase.EnumSubclasses(cl).Members(randi([1,nMembers],ValueShape)));
                
                invalidValue        = char(randi([32,126],1,30));
                invalidValueName  	= invalidValue;
                invalidValue        = {invalidValue};
                
                invalidValueSome    = value;
                invalidValueSome(1) = invalidValue;
                
                [tf,info]       = core_validate(className,propertyName,invalidValueSome);
                exp             = true(ValueShape);
                exp(1)          = false;
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                
                % Verify tf
                testCase.verifyEqual(tf,exp,diagnosticsStr)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape,diagnosticsStr)
            end
        end
        function testValidateEnumRequestInvalidAll(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_validate
                import DataKit.enum.validatePropertyName
                
                className       = testCase.EnumSubclasses(cl).Class;
                classHierarchy 	= strsplit(className,'.');
                propertyName  	= [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
                propertyName  	= validatePropertyName(className,propertyName);
                
                invalidValue        = char(randi([32,126],1,30));
                invalidValueName  	= invalidValue;
                invalidValue        = {invalidValue};
                
                invalidValue   	= repmat(invalidValue,ValueShape);
                
                [tf,info]       = core_validate(className,propertyName,invalidValue);
                exp             = false(ValueShape);
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                
                % Verify tf
                testCase.verifyEqual(tf,exp,diagnosticsStr)
                
                % Verify info shape
                testCase.verifySize(info,ValueShape,diagnosticsStr)
            end
        end
	end
end
