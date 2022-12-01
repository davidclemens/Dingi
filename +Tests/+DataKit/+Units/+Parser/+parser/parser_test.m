classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) parser_test < matlab.unittest.TestCase
    % parser_test  Unittests for DataKit.Units.Parser.parser.parser
    % This class holds the unittests for the DataKit.Units.Parser.parser.parser method.
    %
    % It can be run with runtests('Tests.DataKit.Units.Parser.parser.parser_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        Sign = {
            {'','%s'} % Implicit positive
            {'+','(+ %s)'} % Explicit positive
            {'-','(- %s)'} % Negative
            }
        Variables = {...
            {'3'} % Integer
            {'0'} % Zero integer
            {'2e5'} % Integer with positive exponent
            {'2e-5'} % Integer with negative exponent
            {'3.14'} % Float variation 1
            {'.14'} % Float variation 2
            {'3.14e4'} % Float with positive integer exponent
            {'3.14e-4'} % Float with negative integer exponent
            {'meter'} % Unit
            {'meter2'} % Unit with number
            {'meter_two'} % Unit with underscore
            {'[length]'} % Dimension
            }
        Expressions = {...
            {'%s',1,'%s'} % Scalar
            {'%s + %s',2,'(%s + %s)'} % Addition: 2 summands
            {'%s - %s',2,'(%s - %s)'} % Subtraction: 2 summands
            {'%s * %s',2,'(%s * %s)'} % Multiplication: 2 factors
            {'%s / %s',2,'(%s / %s)'} % Division: 2 factors
            {'%s + %s + %s',3,'((%s + %s) + %s)'} % Addition: 3 summands
            {'%s - %s - %s',3,'((%s - %s) - %s)'} % Subtraction: 3 summands
            {'%s * %s * %s',3,'((%s * %s) * %s)'} % Multiplication: 3 factors
            {'%s / %s / %s',3,'((%s / %s) / %s)'} % Division: 3 factors
            {'%s + %s - %s',3,'((%s + %s) - %s)'} % Mixed: 3 parts
            {'%s + %s * %s',3,'(%s + (%s * %s))'} % Mixed: 3 parts
            {'%s * %s + %s',3,'((%s * %s) + %s)'} % Mixed: 3 parts
            {'-%s',1,'(- %s)'} % Unary minus operator
            {'+%s',1,'(+ %s)'} % Unary plus operator
            {'--%s',1,'(- (- %s))'} % Double unary minus operator
            {'++%s',1,'(+ (+ %s))'} % Double unary plus operator
            }
        ExpressionsPower = {...
            {'%s ^ %s',2,'(%s ^ %s)'} % Power: 1 exponent
            {'%s ^ %s ^ %s',3,'(%s ^ (%s ^ %s))'} % Power: 2 exponents
            {'%s + %s * %s ^ %s',4,'(%s + (%s * (%s ^ %s)))'} % Mixed: 4 parts
            {'%s + %s ^ %s * %s',4,'(%s + ((%s ^ %s) * %s))'} % Mixed: 4 parts
            {'%s ^ %s + %s * %s',4,'((%s ^ %s) + (%s * %s))'} % Mixed: 4 parts
            {'%s ^ %s * %s + %s',4,'(((%s ^ %s) * %s) + %s)'} % Mixed: 4 parts
            }
        Pint = {...
            {'3', '3'}
            {'1 + 2', '(1 + 2)'}
            {'2 * 3 + 4', '((2 * 3) + 4)'}  % order of operations
            {'2 * (3 + 4)', '(2 * (3 + 4))'}  % parentheses
            {'1 + 2 * 3 ^ (4 + 3 / 5)','(1 + (2 * (3 ^ (4 + (3 / 5)))))'}  % more order of operations
            {'1 * ((3 + 4) * 5.34)','(1 * ((3 + 4) * 5.34))'}  % nested parentheses at beginning
            {'1 * (5 * (3 + 4))', '(1 * (5 * (3 + 4)))'}  % nested parentheses at end
            {'1 * (5 * (3e2 + 4) / 6)','(1 * ((5 * (3e2 + 4)) / 6))'}  % nested parentheses in middle
            {'-1', '(- 1)'}  % unary
            {'3 * -1', '(3 * (- 1))'}  % unary
            {'3 * --1', '(3 * (- (- 1)))'}  % double unary
            {'3 * -(2 + 4.2e+3)', '(3 * (- (2 + 4.2e+3)))'}  % parenthetical unary
            {'3 * -((2.3e2 + 4))', '(3 * (- (2.3e2 + 4)))'}  % parenthetical unary
            {'3 4', '(3 4)'} % implicit op
            {'3 (2 + 4)', '(3 (2 + 4))'} % implicit op, then parentheses
            {'(3 ^ 4 ) 5', '((3 ^ 4) 5)'} % parentheses, then implicit
            {'3 4 ^ 5', '(3 (4 ^ 5))'} % implicit op, then exponentiation
            {'3 4 + 5', '((3 4) + 5)'} % implicit op, then addition
            {'3 ^ 4 5', '((3 ^ 4) 5)'} % power followed by implicit
            {'3 (4 ^ 5)', '(3 (4 ^ 5))'} % implicit with parentheses
            {'3e-1', '3e-1'} % exponent with e
            {'kg ^ 1 * s ^ 2', '((kg ^ 1) * (s ^ 2))'} % multiple units with exponents
            {'kg ^ -1 * s ^ -2', '((kg ^ (- 1)) * (s ^ (- 2)))'} % multiple units with neg exponents
            {'kg^-1 * s^-2', '((kg ^ (- 1)) * (s ^ (- 2)))'} % multiple units with neg exponents
            {'kg^-1 s^-2', '((kg ^ (- 1)) (s ^ (- 2)))'} % multiple units with neg exponents, implicit op
            {'2 ^ 3 ^ 2', '(2 ^ (3 ^ 2))'} % nested power
            {'gram * second / meter ^ 2', '((gram * second) / (meter ^ 2))'} % nested power
            {'gram / meter ^ 2 / second', '((gram / (meter ^ 2)) / second)'} % nested power
            % units should behave like numbers, so we don't need a bunch of extra tests for them
            {'3 kg + 5', '((3 kg) + 5)'} % implicit op, then addition
            {'3 [mass] [length]^-3', '((3 [mass]) ([length] ^ (- 3)))'} % dimensions
        }
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testExpressionsNoPower(testCase,Sign,Variables,Expressions)
            
            substitutesIn       = repmat(strcat(Sign{1},Variables),1,Expressions{2});
            substitutesExp      = repmat({sprintf(Sign{2},Variables{:})},1,Expressions{2});
            expressionIn        = sprintf(Expressions{1},substitutesIn{:});
            expressionExp       = sprintf(Expressions{3},substitutesExp{:});
            
            P       = DataKit.Units.Parser.parser(expressionIn,'Expr');
            
            act     = P.Tree.char;
            exp     = expressionExp;
            
            testCase.verifyEqual(act,exp);
        end
        function testExpressionsPower(testCase,Variables,ExpressionsPower)
            
            substitutesIn       = repmat(Variables,1,ExpressionsPower{2});
            substitutesExp      = repmat(Variables,1,ExpressionsPower{2});
            expressionIn        = sprintf(ExpressionsPower{1},substitutesIn{:});
            expressionExp       = sprintf(ExpressionsPower{3},substitutesExp{:});
            
            P       = DataKit.Units.Parser.parser(expressionIn,'Expr');
            
            act     = P.Tree.char;
            exp     = expressionExp;
            
            testCase.verifyEqual(act,exp);
        end
        function testPintUnitTests(testCase,Pint)
            
            P       = DataKit.Units.Parser.parser(Pint{1},'Expr');
            
            act     = P.Tree.char;
            exp     = Pint{2};
            
            testCase.verifyEqual(act,exp);            
        end
    end
end
