classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) power_test < matlab.unittest.TestCase
    % power_test  Unittests for DataKit.Units.dimension.power
    % This class holds the unittests for the DataKit.Units.dimension.power
    % method.
    %
    % It can be run with runtests('Tests.DataKit.Units.dimension.power_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        In1 = struct(...
        	'Number',           3,...
            'Dimension',        DataKit.Units.dimension('length'),...
            'LongDimension',    DataKit.Units.dimension('length')*DataKit.Units.dimension('length')*DataKit.Units.dimension('mass'))
        In2 = struct(...
        	'Number',           -2,...
            'Dimension',        DataKit.Units.dimension('time'),...
            'LongDimension',    DataKit.Units.dimension('mass')*DataKit.Units.dimension('illuminance')*DataKit.Units.dimension('time'))
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        %%{
        function testValidDimensions(testCase,In1,In2)
            
            import DataKit.Units.dimension
            
            isDimension     	= cat(2,isa(In1,'DataKit.Units.dimension'),isa(In2,'DataKit.Units.dimension'));
            inputs              = {In1,In2};
            
            if sum(isDimension) == 0
                expected = In1.^In2;
            elseif isDimension(1) && ~isDimension(2)
                exponents2 	= inputs{2};
             	dims        = inputs{1}.Dimensions;
                exponents 	= inputs{1}.Degrees + exponents2;
                value    	= strjoin(strcat(dims,{'^'},arrayfun(@num2str,exponents,'un',0)),'*');
                
                expected = dimension(value);
            elseif ~isDimension(1) && isDimension(2)
                %testCase.verifyError(@() In1.^In2,'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression')
                return
            elseif sum(isDimension) == 2
                %testCase.verifyError(@() In1.^In2,'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression')
                return
            end
            
            actual = In1.^In2;
            
            testCase.verifyEqual(actual,expected)
        end
    end
end
