classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) variable2id_test < matlab.unittest.TestCase
    
    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.variable.variable2id_test);
    % run(tests)
    
    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        
    end
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function invalidVariableId(testCase)
            
            variableIdUnknown   = 22;
            testCase.verifyError(@() DataKit.Metadata.variable.validateId(variableIdUnknown),...
                'DataKit:Metadata:variable:variableFromId:invalidVariableId');
        end
        function validVariableId(testCase)
            
            variableIdKnown   = 20;
            act     = DataKit.Metadata.variable.validateId(variableIdKnown);
            exp     = true;
            testCase.verifyEqual(act,exp)            
        end
        
        function invalidVariableIdDataType(testCase)
            
            variableId   = '20';
            testCase.verifyError(@() DataKit.Metadata.variable.validateId(variableId),...
                'DataKit:Metadata:variable:validateId:invalidIdDataType');        
        end
	end
end