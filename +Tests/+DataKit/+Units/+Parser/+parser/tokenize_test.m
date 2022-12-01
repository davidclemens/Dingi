classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) tokenize_test < matlab.unittest.TestCase
    % tokenize_test  Unittests for DataKit.Units.Parser.parser.tokenize
    % This class holds the unittests for the DataKit.Units.Parser.parser.tokenize method.
    %
    % It can be run with runtests('Tests.DataKit.Units.Parser.parser.tokenize_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        Numbers = {...
            {'3','NUMBER','INT'} % Integer
            {'0','NUMBER','INT'} % Zero integer
            {'2e5','NUMBER','FLOAT'} % Integer with positive exponent
            {'2e-5','NUMBER','FLOAT'} % Integer with negative exponent
            {'3.14','NUMBER','FLOAT'} % Float variation 1
            {'.14','NUMBER','FLOAT'} % Float variation 2
            {'3.14e4','NUMBER','FLOAT'} % Float with positive integer exponent
            {'3.14e-4','NUMBER','FLOAT'} % Float with negative integer exponent
            }
        Names = {...
            {'meter','NAME','VAR'} % Unit
            {'meter2','NAME','VAR'} % Unit with number
            {'meter_two','NAME','VAR'} % Unit with underscore
            {'[length]','NAME','DIM'} % Dimension
            {'[length2]','NAME','DIM'} % Dimension with number
            {'[length_two]','NAME','DIM'} % Dimension with underscore
            }
        Operators = {...
            {'+','OP','OP'}
            {'-','OP','OP'}
            {'*','OP','OP'}
            {'/','OP','OP'}
            {'^','OP','OP'}
            {'(','OP','DELIM'}
            {')','OP','DELIM'}
            }
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testNumbers(testCase,Numbers)
            
            act = DataKit.Units.Parser.parser.tokenize(Numbers{1});
            exp = struct(...
                'Text',         Numbers{1},...
                'Type',         Numbers{2},...
                'ExactType',    Numbers{3});
            
            testCase.verifyEqual(act,exp);            
        end
        function testNames(testCase,Names)
            
            act = DataKit.Units.Parser.parser.tokenize(Names{1});
            exp = struct(...
                'Text',         Names{1},...
                'Type',         Names{2},...
                'ExactType',    Names{3});
            
            testCase.verifyEqual(act,exp);            
        end
        function testOperators(testCase,Operators)
            
            act = DataKit.Units.Parser.parser.tokenize(Operators{1});
            exp = struct(...
                'Text',         Operators{1},...
                'Type',         Operators{2},...
                'ExactType',    Operators{3});
            
            testCase.verifyEqual(act,exp);            
        end
        function testMixedNoSpace(testCase,Numbers,Names,Operators)
            
            in  = cat(1,Numbers,Operators,Names);
            stream = cat(2,in{:,1});
            act = DataKit.Units.Parser.parser.tokenize(stream);
            exp = cell2struct(in,{'Text','Type','ExactType'},2);
            
            testCase.verifyEqual(act,exp);            
        end
        function testMixedWidthSpace(testCase,Numbers,Names,Operators)
            
            in  = cat(1,Numbers,Operators,Names);
            stream = strjoin(in(:,1),' ');
            act = DataKit.Units.Parser.parser.tokenize(stream);
            exp = cell2struct(in,{'Text','Type','ExactType'},2);
            
            testCase.verifyEqual(act,exp);            
        end
    end
end
