classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) times_test < matlab.unittest.TestCase
    % times_test  Unittests for DataKit.Units.dimension.times
    % This class holds the unittests for the DataKit.Units.dimension.times
    % method.
    %
    % It can be run with runtests('Tests.DataKit.Units.dimension.times_test').
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
            'LongDimension',    DataKit.Units.dimension('bigDim',DataKit.Units.dimension('length')*DataKit.Units.dimension('mass')))
        In2 = struct(...
        	'Number',           -2,...
            'Dimension',        DataKit.Units.dimension('time'),...
            'LongDimension',    DataKit.Units.dimension('bigDim',DataKit.Units.dimension('illuminance')^-4*DataKit.Units.dimension('time')))
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
            
            actual = In1.*In2;
            
            if sum(isDimension) == 0
                expected = In1.*In2;
            elseif isDimension(1) && ~isDimension(2)
                expected = inputs{1};
            elseif ~isDimension(1) && isDimension(2)
                expected = inputs{2};
            elseif sum(isDimension) == 2
             	dims1       = inputs{1}.Dimensions;
                exponents1 	= inputs{1}.Degrees;
                value1    	= strjoin(strcat(dims1,{'^'},arrayfun(@num2str,exponents1,'un',0)),'*');
             	dims2       = inputs{2}.Dimensions;
                exponents2 	= inputs{2}.Degrees;
                value2    	= strjoin(strcat(dims2,{'^'},arrayfun(@num2str,exponents2,'un',0)),'*');
                value       = ['(',value1,')*(',value2,')'];
                
                expected = dimension(value);
            end
            
            testCase.verifyEqual(actual,expected)
        end
    end
end
