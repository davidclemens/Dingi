classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) getDimensionality_test < matlab.unittest.TestCase
    % getDimensionality_test  Unittests for DataKit.Units.Parser.evalTreeNode.getDimensionality
    % This class holds the unittests for the 
    % DataKit.Units.Parser.evalTreeNode.getDimensionality method.
    %
    % It can be run with runtests('Tests.DataKit.Units.Parser.evalTreeNode.getDimensionality_test').
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
            {'3 ^ 10', {},[]}
            {'meter * km', {'meter';'km'},[1;1]}
            {'meter / km', {'meter';'km'},[1;-1]}
            {'meter / km / km', {'meter';'km'},[1;-2]}
            {'meter / (km / km)', {'meter'},1}
            {'meter / km^-1', {'meter';'km'},[1;1]}
            {'km (3 - 10)', {'km'},1}
            {'(km (3 - 10))^5', {'km'},5}
            {'mol/(meter^2*day)', {'mol';'meter';'day'},[1;-2;-1]}
            {'mol/(meter^2*day*mol^-3)', {'mol';'meter';'day'},[4;-2;-1]}
            {'1/[length]', {'[length]'},-1}
            }
        Errors = {
            {'meter ^ km', 'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression'}
            {'meter + km', 'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression'}
            {'meter + 5',  'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression'} % TODO: is this expected behaviour? The dimensionality of the variable is not affected by the added numeric scalar.
            }
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testValidExpressions(testCase,Expressions)
            
            P = DataKit.Units.Parser.parser(Expressions{1},'Expr');
            
            [actNames,actDimensionality] = P.Tree.getDimensionality;
            expNames          	= Expressions{2};
            expDimensionality   = Expressions{3};
            
            testCase.verifyEqual(actNames,expNames);
            testCase.verifyEqual(actDimensionality,expDimensionality);
        end
        function testErrors(testCase,Errors)
            
            P = DataKit.Units.Parser.parser(Errors{1},'Expr');
            
            errorId = Errors{2};
            
            testCase.verifyError(@() P.Tree.getDimensionality,errorId)
        end
    end
end
