classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) subsasgn_test < matlab.unittest.TestCase
    
% run and stop if verification fails:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.subsasgn_test);
%     runner    = matlab.unittest.TestRunner.withTextOutput;
%     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
%     runner.run(tests)
% run :
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.subsasgn_test);
%     run(tests)
    
    properties
        Ain = uint8([...
                17    24     5
                 4     8    20])
        obj
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        
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
        function testStorageTypeIncrease(testCase)
            
            act     = testCase.obj;
            subs    = {1};
            num     = 2^17;
            
            act(subs{:})    = num;
            exp             = uint32(testCase.Ain);
            exp(subs{:})    = num;
            
            testCase.verifyEqual(act.Bits,exp);
        end
        function testStorageTypeDecrease(testCase)
            
            act     = testCase.obj;
            act     = act.setBit(64,1,1,1);
            
            subs    = {1};
            num     = testCase.Ain(1);
            
            act(subs{:})    = num;
            exp             = testCase.Ain;
            exp(subs{:})    = num;
            
            testCase.verifyEqual(act.Bits,exp);
        end
	end
end