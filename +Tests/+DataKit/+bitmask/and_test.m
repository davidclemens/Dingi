classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) and_test < matlab.unittest.TestCase
    % and_test  Unittests for DataKit.bitmask.and
    % This class holds the unittests for the DataKit.bitmask.and method.
    %
    % It can be run with runtests('Tests.DataKit.bitmask.and_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        Ain = [...
               512    24     5
                 4     8    20]
        obj
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % {Shape}
        % Where:
        %   Shape: S (scalar), VR (row vector), VC (column vector), M (matrix)
        B = struct(...
            'S',            struct(...
                'B',        3,...
                'exp',      uint8([0,0,1;0,0,0])),...
            'VR',           struct(...
                'B',        [7,1,11],...
                'exp',      uint8([0,0,1;4,0,0])),...
            'VC',           struct(...
                'B',        [7;11],...
                'exp',      uint8([0,0,5;0,8,0])),...
            'M',           struct(...
                'B',        [555,30,3;41,19,4],...
                'exp',      uint16([512,24,1;0,0,4]))...
            )
    end
    
    methods (TestClassSetup)
        function createInitialBitmask(testCase)
            
            import DataKit.bitmask
            
            testCase.obj = bitmask(testCase.Ain);
        end
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
    end
    
    methods (Test)        
        function testDotSubsrefProperty(testCase,B)
            
            bfA     = testCase.obj;
            bfB     = DataKit.bitmask(B.B);
            bfAct   = bfA & bfB;
            
            act     = bfAct.Bits;
            exp     = B.exp;
            
            testCase.verifyEqual(act,exp);
        end
    end
end
