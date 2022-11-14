classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) size_test < matlab.unittest.TestCase
    % size_test  Unittests for DataKit.bitmask.size
    % This class holds the unittests for the DataKit.bitmask.size method.
    %
    % It can be run with runtests('Tests.DataKit.bitmask.size_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
        
    methods (Test)
        % Test different sizes
        function testSizeEmpty(testCase)
            
            bm = DataKit.bitmask();
            
            act = size(bm);
            exp = [0 0];
            
            testCase.verifyEqual(act,exp);
        end
        function testSizeScalar(testCase)
            
            bm = DataKit.bitmask(0);
            
            act = size(bm);
            exp = [1 1];
            
            testCase.verifyEqual(act,exp);
        end
        function testSizeRowVector(testCase)
            
            sz = [5,1];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm);
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
        function testSizeColVector(testCase)
            
            sz = [1,6];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm);
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
        function testSize2DArray(testCase)
            
            sz = [2,6];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm);
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
        function testSizeNDArray(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm);
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
    
        % Test return types
        function testReturnOneArg(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm);
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
        function testReturnTwoArg(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            [act1,act2] = size(bm);
            act = [act1,act2];
            exp = [sz(1),prod(sz(2:end))];
            
            testCase.verifyEqual(act,exp);
        end
        function testReturnAllArg(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            [act1,act2,act3,act4,act5] = size(bm);
            act = [act1,act2,act3,act4,act5];
            exp = sz;
            
            testCase.verifyEqual(act,exp);
        end
        function testReturnExcessArg(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            [act1,act2,act3,act4,act5,act6,act7] = size(bm);
            act = [act1,act2,act3,act4,act5,act6,act7];
            exp = [sz,1,1];
            
            testCase.verifyEqual(act,exp);
        end
        function testReturnExcessArg1(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            [act1,act2,act3,act4,act5,act6,act7] = bm.size;
            act = [act1,act2,act3,act4,act5,act6,act7];
            exp = [sz,1,1];
            
            testCase.verifyEqual(act,exp);
        end
        
        % Test input arguments
        function testInputArg(testCase)
            
            sz = [2,6,3,1,3];
            bm = DataKit.bitmask(zeros(sz));
            
            act = size(bm,3);
            exp = 3;
            
            testCase.verifyEqual(act,exp);
        end
    end
end
