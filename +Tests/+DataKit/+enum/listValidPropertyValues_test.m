classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) listValidPropertyValues_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.enum.listValidPropertyValues_test);
    % run(tests)

    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        ClassName = struct(...
            'valid',...
                struct(...
                    'TestType',         '',...
                    'ClassName',        'GearKit.deviceDomain'),...
            'invalidClassName',...
                struct(...
                    'TestType',         'Error',...
                    'ClassName',        'jfkdlöajkelöajfkdlö',...
                    'ExpectedErrorId',  'Dingi:DataKit:enum:validateClassName:InvalidClassName'),...
            'invalidClassNameType',...
                struct(...
                    'TestType',         'Error',...
                    'ClassName',        43,...
                    'ExpectedErrorId',  'Dingi:DataKit:enum:validateClassName:invalidInputType'))
        PropertyName = struct(...
            'valid',...
                struct(...
                    'TestType',         '',...
                    'PropertyName',     'Abbreviation'),...
            'invalidPropertyName',...
                struct(...
                    'TestType',         'Error',...
                    'PropertyName',     'qerjfkldsjaieöfjdklaö',...
                    'ExpectedErrorId',  'Dingi:DataKit:enum:validatePropertyName:invalidPropertyName'),...
            'invalidPropertyNameType',...
                struct(...
                    'TestType',         'Error',...
                    'PropertyName',     43,...
                    'ExpectedErrorId',  'Dingi:DataKit:enum:validatePropertyName:invalidInputType'))
    end

    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
      
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testValids(testCase,ClassName,PropertyName)
            
            import DataKit.enum.listValidPropertyValues
            
            if strcmp('Error',PropertyName.TestType) || strcmp('Error',ClassName.TestType)
                return
            end
            enumerationMembers = enumeration(ClassName.ClassName);
            exp     = {enumerationMembers.(PropertyName.PropertyName)}';
            
            act     = listValidPropertyValues(ClassName.ClassName,PropertyName.PropertyName);

            testCase.verifyEqual(act,exp);
        end
        function testErrors(testCase,ClassName,PropertyName)
            
            import DataKit.enum.listValidPropertyValues
            
            if strcmp('',PropertyName.TestType) || strcmp('',ClassName.TestType)
                return
            end
            
            if strcmp('Error',PropertyName.TestType)
                exp	= PropertyName.ExpectedErrorId;
            end
            if strcmp('Error',ClassName.TestType)
                exp	= ClassName.ExpectedErrorId;
            end
            
            testCase.verifyError(@() ...
                listValidPropertyValues(ClassName.ClassName,PropertyName.PropertyName),...
                exp)
        end
	end
end
