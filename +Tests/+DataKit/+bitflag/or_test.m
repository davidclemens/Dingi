classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) or_test < matlab.unittest.TestCase
    % or_test  Unittests for DataKit.bitflag.or
    % This class holds the unittests for the DataKit.bitflag.or method.
    %
    % It can be run with runtests('Tests.DataKit.bitflag.or_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        Ain = [...
               512    24     5
                 4     8    20]
        objEnumName = 'DataKit.Metadata.validators.validFlag'
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
                'exp',      uint16([515,27,7;7,11,23])),...
            'VR',           struct(...
                'B',        [7,1,11],...
                'exp',      uint16([519,25,15;7,9,31])),...
            'VC',           struct(...
                'B',        [7;11],...
                'exp',      uint16([519,31,7;15,11,31])),...
            'M',           struct(...
                'B',        [555,30,3;41,19,4],...
                'exp',      uint16([555,30,7;45,27,20]))...
            )
    end
    
    methods (TestClassSetup)
        function createInitialBitmask(testCase)
            
            import DataKit.bitflag
            
            testCase.obj = bitflag(testCase.objEnumName,testCase.Ain);
        end
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
    end
    
    methods (Test)        
        function testDotSubsrefProperty(testCase,B)
            
            bfA     = testCase.obj;
            bfB     = DataKit.bitflag(testCase.objEnumName,B.B);
            bfAct   = bfA | bfB;
            
            act     = bfAct.Bits;
            exp     = B.exp;
            
            testCase.verifyEqual(act,exp);
        end
    end
end
