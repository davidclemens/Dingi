classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) core_fromProperty_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.enum.core_fromProperty_test);
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
        function testFromPropertyValid(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_fromProperty
                
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
                act             = core_fromProperty(className,propertyName,value);
                exp             = repmat(testCase.EnumSubclasses(cl).Members(end),ValueShape);
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,valueName,num2str(ValueShape));
                testCase.verifyEqual(act,exp,diagnosticsStr)
            end
        end
        function testFromPropertyInvalidValueType(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_fromProperty
                
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
                    core_fromProperty(className,propertyName,invalidValue),...
                    'Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                    diagnosticsStr)
            end
        end
        function testFromPropertyInvalidValueAll(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_fromProperty
                
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
                
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                testCase.verifyError(@() ...
                    core_fromProperty(className,propertyName,invalidValue),...
                    'Dingi:DataKit:enum:validatePropertyValues:invalidPropertyValue',...
                    diagnosticsStr)
            end
        end
        function testFromPropertyInvalidValueSome(testCase,ValueShape)
            for cl = 1:testCase.NEnumSubclasses
                
                import DataKit.enum.core_fromProperty
                
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
                
                diagnosticsStr  = sprintf('EnumSubclasss: %s\nPropertyName: %s\nPropertyValue: %s\nValueShape: %s\n',className,propertyName,invalidValueName,num2str(ValueShape));
                testCase.verifyError(@() ...
                    core_fromProperty(className,propertyName,invalidValueSome),...
                    'Dingi:DataKit:enum:validatePropertyValues:invalidPropertyValue',...
                    diagnosticsStr)
            end
        end
	end
end
