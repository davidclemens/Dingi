classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) setNum_test < matlab.unittest.TestCase
    % setNum_test  Unittests for DataKit.bitmask.setNum
    % This class holds the unittests for the DataKit.bitmask.setNum method.
    %
    % It can be run with runtests('Tests.DataKit.bitmask.setNum_test').
    %
    %
    % Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        obj
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)        
        % {IndexType}_{IndexShape}_{IndexIsWithinShape}_{IndexHasNewDimension}
        % Where:
        %   IndexType: lInd (linear index), sub (subscripted index)
        %   IndexShape: U (uniform), V (vector)
        %   IndexIsWithinShape: T (true), F (false)
        %   IndexHasNewDimension: T (true), F (false)
        sub = struct(...
            'lInd_U_T_F', 	struct(...
                                'subs',     {{3}},...
                                'num',      7,...
                                'exp',      uint8([17,7,5;4,8,20])),...
            'lInd_U_F_F',  	struct(...
                                'subs',     {{8}},...
                                'num',      7,...
                                'exp',      uint8([17,24,5,0;4,8,20,7])),...
            'sub_U_T_F',   	struct(...
                                'subs',     {{2,2}},...
                                'num',      7,...
                                'exp',      uint8([17,24,5;4,7,20])),...
            'sub_U_F_F', 	struct(...
                                'subs',     {{2,5}},...
                                'num',      7,...
                                'exp',      uint8([17,24,5,0,0;4,8,20,0,7])),...
            'sub_U_F_T', 	struct(...
                                'subs',     {{2,5,2}},...
                                'num',      7,...
                                'exp',      uint8(cat(3,[17,24,5,0,0;4,8,20,0,0],[0,0,0,0,0;0,0,0,0,7]))),...
            'sub_V_T_F',   	struct(...
                                'subs',     {{[2;1],[2;3]}},...
                                'num',      [7;3],...
                                'exp',      uint8([17,24,3;4,7,20])),...
            'sub_V_F_F',    struct(...
                                'subs',     {{[2;1],[10;7]}},...
                                'num',      [7;3],...
                                'exp',      uint8([17,24,5,0,0,0,3,0,0,0;4,8,20,0,0,0,0,0,0,7])),...
            'sub_V_F_T',  	struct(...
                                'subs',     {{[2;1],[10;7],[2;3]}},...
                                'num',      [7;3],...
                                'exp',      uint8(cat(3,[17,24,5,0,0,0,0,0,0,0;4,8,20,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,7],[0,0,0,0,0,0,3,0,0,0;0,0,0,0,0,0,0,0,0,0]))))
    end
    
    methods (TestClassSetup)
        function createInitialBitmask(testCase)
            
            import DataKit.bitmask
            
          	Ain = [...
                17    24     5
                 4     8    20];
            testCase.obj = bitmask(Ain);
        end
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
    end
    
    methods (Test)
        function testStorageTypeIncrease(testCase)
            
            import DataKit.bitmask
            
            bm  = bitmask(0);
            
            act = bm.setNum(intmax('uint64'),1,1);
            exp = intmax('uint64');
            
            testCase.verifyEqual(act.Bits,exp);
        end
        function testStorageTypeDecrease(testCase)
            
            import DataKit.bitmask
            
            bm  = bitmask(1,1,64);
            
            act = bm.setNum(0,1,1);
            exp = zeros(1,'uint8');
            
            testCase.verifyEqual(act.Bits,exp);
        end        
        function testSetNum2(testCase,sub)
            
            S       = substruct('()',sub.subs);
            B       = sub.num;
            exp     = sub.exp;
            
            actBf   = subsasgn(testCase.obj,S,B);
            act     = actBf.Bits;
            testCase.verifyEqual(act,exp);
        end
	end
end
