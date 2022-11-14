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
        % Input parameters to test for the following input schemes:
        %     obj = setBit(obj,bit,highlow,dim1,dim2,...)
        %
        %   {bit}_{highlow}_{sub}
        % where
        %   num: S (same), D (different)
        %   sub: S (same), D (different)
        
        % Naming convention:
        %   {InputsAreEqual}_{ExistingNumIsEqual}
        num = struct(...
            'T_T',  [17,17],...
            'T_F',  [30,30],...
            'F_T',  [24,17],...
            'F_F',  [30,30])
        % Naming convention:
        %   {IndicesAreEqual}
        dim = struct(...
            'A',  	{{[1 1],...
                      [1 1]}},...
            'B',    {{[1 1],...
                      [1 2]}},...
            'C',    {{[1 1],...
                      [2 2]}})
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
        function testSetBit(testCase,num,dim)
            
            ind = sub2ind(testCase.obj.Size,dim{:});
            exp = testCase.obj.Bits;
            exp(ind) = num;
            act = testCase.obj.setNum(num,dim{:});
            
            testCase.verifyEqual(act.Bits,exp)
        end
	end
end
