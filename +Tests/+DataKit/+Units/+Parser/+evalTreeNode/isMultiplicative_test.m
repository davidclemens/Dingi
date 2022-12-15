classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) isMultiplicative_test < matlab.unittest.TestCase
    % isMultiplicative_test  Unittests for DataKit.Units.Parser.evalTreeNode.isMultiplicative
    % This class holds the unittests for the 
    % DataKit.Units.Parser.evalTreeNode.isMultiplicative method.
    %
    % It can be run with runtests('Tests.DataKit.Units.Parser.evalTreeNode.isMultiplicative_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        Expressions = {
            {'1', true}
            {'3 + 10', true}
            {'3 - 10', true}
            {'3 * 10', true}
            {'3 / 10', true}
            {'3 ^ 10', true}
            {'meter + km', false}
            {'meter - km', false}
            {'meter * km', true}
            {'meter / km', true}
            {'meter ^ km', false}
            {'km (3 - 10)', true}
            {'(km (3 - 10))^5', true}
            {'(km (3 - 10))^(3^meter)', false}
            }
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testIsMultiplicative(testCase,Expressions)
            
            P = DataKit.Units.Parser.parser(Expressions{1},'Expr');
            
            act = P.Tree.isMultiplicative;
            exp = Expressions{2};
            
            testCase.verifyEqual(act,exp);            
        end
    end
end
