classdef (SharedTestFixtures = { matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'}))) }) subsasgn_test < matlab.unittest.TestCase
	% subsasgn_test  Tests bitmask.subsasgn behaviour
    % The SUBSASGN_TEST test class tests the functionality of the
    % DataKit.bitmask.subsasgn method.
    %
    % Run the tests: 
    %   Run and stop if verification fails:
    %     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.subsasgn_test);
    %     runner    = matlab.unittest.TestRunner.withTextOutput;
    %     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
    %     runner.run(tests)
    %   Run:
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
        % {IndexType}_{IndexShape}_{IndexIsWithinShape}_{IndexHasNewDimension}
        % Where:
        %   IndexType: lInd (linear index), sub (subscripted index)
        %   IndexShape: U (uniform), V (vector)
        %   IndexIsWithinShape: T (true), F (false)
        %   IndexHasNewDimension: T (true), F (false)
        sub = struct(...
            'lInd_U_T_F', 	struct(...
                                'subs',     {{3}},...
                                'num',      7),...
            'lInd_U_F_F',  	struct(...
                                'subs',     {{8}},...
                                'num',      7),...
            'sub_U_T_F',   	struct(...
                                'subs',     {{2,2}},...
                                'num',      7),...
            'sub_U_F_F', 	struct(...
                                'subs',     {{2,5}},...
                                'num',      7),...
            'sub_U_F_T', 	struct(...
                                'subs',     {{2,5,2}},...
                                'num',      7),...
            'sub_V_T_F',   	struct(...
                                'subs',     {{[2;1],[2;3]}},...
                                'num',      [7;3]),...
            'sub_V_F_F',    struct(...
                                'subs',     {{[2;1],[10;7]}},...
                                'num',      [7;3]),...
            'sub_V_F_T',  	struct(...
                                'subs',     {{[2;1],[10;7],[2;5]}},...
                                'num',      [7;3]))
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
        function testSetNum(testCase,sub)
            
            act     = testCase.obj.setNum(sub.num,sub.subs{:});
            exp     = testCase.Ain;
            
            if numel(sub.subs) == 1
                subs        = cell(1,ndims(exp));
                [subs{:}]   = ind2sub(size(exp),sub.subs{:});
            else
                subs    = sub.subs;
            end
            
            subs    = num2cell(cat(2,subs{:}));
            
            for s = 1:size(subs,1)
                exp(subs{s,:}) = sub.num(s);
            end
            
            testCase.verifyEqual(act.Bits,exp);
        end
	end
end