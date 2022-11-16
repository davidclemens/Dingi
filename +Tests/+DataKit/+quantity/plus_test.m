classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) plus_test < matlab.unittest.TestCase
    % plus_test  Unittests for DataKit.quantity.plus
    % This class holds the unittests for the DataKit.quantity.plus method.
    %
    % It can be run with runtests('Tests.DataKit.quantity.plus_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        A = DataKit.quantity(4,0.2,3)
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % {SummandType}_{HasUncertainty}_{Shape}
        % Where:
        %   SummandType: positive (pos), negative (neg), zero (zer), nan (NaN), 
        %     posinf (Inf), neginf (-Inf)
        %   HasUncertainty: T (true), F (false)
        %   Shape: S (scalar), V (vector), M (matrix)
        BMeta = struct(...
            'pos_F_S',      struct(...
                'A',        8,...
                'Sigma',    0,...
                'Flag',     4,...
                'expA',     12,...
                'expSigma', 0.2,...
                'expFlag',  7)...
            );
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testParenthesisSubsref(testCase,BMeta)
            
            B       = DataKit.quantity(BMeta.A,BMeta.Sigma,BMeta.Flag);
            actQ    = testCase.A + B;
            
            act     = cat(3,double(actQ),actQ.Sigma,double(actQ.Flag.Bits));
            exp     = cat(3,BMeta.expA,BMeta.expSigma,BMeta.expFlag);
            
            testCase.verifyEqual(act,exp);
        end
    end
end
