classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) times_test < matlab.unittest.TestCase
    % times_test  Unittests for DataKit.quantity.times
    % This class holds the unittests for the DataKit.quantity.times method.
    %
    % It can be run with runtests('Tests.DataKit.quantity.times_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        A = DataKit.quantity(4,0.2,3)
        sigmaFunc = @(A,B,dA,dB) abs(A.*B).*sqrt((dA./A).^2 + (dB./B).^2);
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % SummandType either positive (pos), negative (neg), zero (zer), nan (NaN), 
        % posinf (Inf) or neginf (-Inf)
        BValue = struct(...
            'pos',      struct(...
                'Value',    8,...
                'expValue', 4*8),...
            'neg',      struct(...
                'Value',    -20,...
                'expValue', 4*-20),...
            'zer',      struct(...
                'Value',    0,...
                'expValue', 0),...
            'nan',      struct(...
                'Value',    NaN,...
                'expValue', NaN),...
            'neginf',  	struct(...
                'Value',    -Inf,...
                'expValue', -Inf),...
            'posinf',   struct(...
                'Value',    Inf,...
                'expValue', Inf)...
            );
        
        % Uncertainty either positive (pos), zero (zer) or NaN (nan)
        BSigma = struct(...
            'pos',      struct(...
                'Sigma',    0.1,...
                'expSigma', []),...
            'zer',      struct(...
                'Sigma',    0,...
                'expSigma', []),...
            'nan',      struct(...
                'Sigma',    NaN,...
                'expSigma', [])...
            );
        
        % Flag 
        BFlag = struct(...
            'match',    struct(...
                'Flag',     14,...
                'expFlag',  15)...
            );
        
        % Shapes: scalar (S), row vector (VR), column vector (VC) or matrix (M)
        BSize = struct(...
            'S',        struct(...
                'sz',       [1,1],...
                'expSz',    [1,1]),...
            'VR',        struct(...
                'sz',       [1,5],...
                'expSz',    [1,5]),...
            'VC',        struct(...
                'sz',       [3,1],...
                'expSz',    [3,1]),...
            'M',         struct(...
                'sz',       [3,2],...
                'expSz',    [3,2])...
            )
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test)
        function testTimesArithmetic(testCase,BValue,BSigma,BFlag)
            
            B       = DataKit.quantity(BValue.Value,BSigma.Sigma,BFlag.Flag);
            actQ    = testCase.A.*B;
            
            expSigma    = testCase.sigmaFunc(double(testCase.A),BValue.Value,testCase.A.Sigma,BSigma.Sigma);
            
            act     = cat(3,double(actQ),actQ.Sigma,double(actQ.Flag.Bits));
            exp     = cat(3,BValue.expValue,expSigma,BFlag.expFlag);
            
            testCase.verifyEqual(act,exp);
        end
        function testTimesShapeCombinations(testCase,BSize)
            
            value   = 20.*rand(BSize.sz) - 10;
            B       = DataKit.quantity(value,zeros(BSize.sz),zeros(BSize.sz));
            actQ    = testCase.A.*B;
            
            expSigma    = testCase.sigmaFunc(double(testCase.A),value,testCase.A.Sigma,zeros(BSize.sz));

            act     = cat(3,double(actQ),actQ.Sigma,double(actQ.Flag.Bits));
            exp     = cat(3,double(testCase.A).*value,expSigma,repmat(double(testCase.A.Flag.Bits),BSize.sz));
            
            testCase.verifyEqual(act,exp);
        end
    end
end
