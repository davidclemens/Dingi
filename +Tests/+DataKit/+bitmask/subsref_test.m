classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) subsref_test < matlab.unittest.TestCase
    % subsref_test  Unittests for DataKit.bitmask.subsref
    % This class holds the unittests for the DataKit.bitmask.subsref method.
    %
    % It can be run with runtests('Tests.DataKit.bitmask.subsref_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        Ain = uint8([...
                17    24     5
                 4     8    20])
        obj
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % {IndexType}_{SubscriptType}_{Index1Shape}_{Index2Shape}
        % Where:
        %   IndexType: lInd (linear index), sub (subscripted index)
        %   SubscriptType: Par ('()'), dot ('.'), brace ('{}') 
        %   Index1Shape: S (scalar), V (vector)
        %   Index2Shape: S (scalar), V (vector)
        subPar = struct(...
            'lInd_par_S', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{3}},...
                                'exp',      uint8(24)),...
            'lInd_par_VS', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{[3,5,6]}},...
                                'exp',      uint8([24,5,20])),...
            'sub_par_S_S', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{2,3}},...
                                'exp',      uint8(20)),...
            'sub_par_S_V', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{2,2:3}},...
                                'exp',      uint8([8,20])),...
            'sub_par_V_S', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{1:2,2}},...
                                'exp',      uint8([24;8])),...
            'sub_par_V_V', 	struct(...
                                'type',     {'()'},...
                                'subs',     {{1:2,[1,3]}},...
                                'exp',      uint8([17,5;4,20]))...
            );
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
        function testParenthesisSubsref(testCase,subPar)
            
            act     = subsref(testCase.obj,substruct(subPar.type,subPar.subs));
            exp     = subPar.exp;
            
            testCase.verifyEqual(act.Bits,exp);
        end
        
        function testDotSubsrefProperty(testCase)
            bm      = testCase.obj;
            
            act     = bm.Size;
            exp     = [2,3];
            
            testCase.verifyEqual(act,exp);
        end
        function testDotSubsrefMethod01(testCase)
            bm      = testCase.obj;
            
            act     = bm.size;
            exp     = [2,3];
            
            testCase.verifyEqual(act,exp);
        end
    end
end
