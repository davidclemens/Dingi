classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) setBit_test < matlab.unittest.TestCase
    
% run and stop if verification fails:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.setBit_test);
%     runner    = matlab.unittest.TestRunner.withTextOutput;
%     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
%     runner.run(tests)
% run :
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.setBit_test);
%     run(tests)
    
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
        %   bit: S (same), D (different)
        %   highlow: S (same), D (different)
        %   sub: S (same), D (different)
        
        % Naming convention:
        %   {InputsAreEqual}_{ExistingBitIsEqual}
        bit = struct(...
            'T_T',  [5,5],...
            'T_F',  [2,2],...
            'F_T',  [1,5],...
            'F_F',  [2,4])
        % Naming convention:
        %   {Highlow}
        highlow = struct(...
            'TT',   [1 1],...
            'TF',   [1 0],...
            'FT',   [0 1],...
            'FF',   [0 0])
        % Naming convention:
        %   {IndicesAreEqual}
        dim = struct(...
            'A',  	{{[1 1],...
                      [1 1]}},...
            'B',    {{[1 1],...
                      [1 2]}},...
            'C',    {{[1 1],...
                      [2 2]}},...
            'D',    {{[1 1]}})
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
            
            bm = bitmask(0);
            
            act = bm.setBit(64,1,1,1);
            exp = bitset(uint64(0),64);
            
            testCase.verifyEqual(act.Bits,exp);
        end
        function testStorageTypeDecrease(testCase)
            
            import DataKit.bitmask
            
            % Scenario A
            bm = bitmask(1,1,64);
            
            bm = bm.setBit(64,0,1,1);
            exp = zeros(1,'uint64');
            act = bm.Bits;
            
            testCase.verifyEqual(act,exp);
            
            % Scenario B
            bm = DataKit.bitmask(zeros(10,10));
            bm = bm.setBit(9,1,1,1);
            bm = bm.setBit(3,1,2,1);
            exp = zeros(10,10,'uint16');
            exp(1,1) = 256;
            exp(2,1) = 4;
            
            act = bm.Bits;
            
            testCase.verifyEqual(act,exp);
        end
        function testSetBit(testCase,bit,highlow,dim)
            
            ind = sub2ind(testCase.obj.Size,dim{:});
            exp = testCase.obj.Bits;
            exp(ind) = bitset(testCase.obj.Bits(ind),bit,highlow);
            act = testCase.obj.setBit(bit,highlow,dim{:});
            
            testCase.verifyEqual(act.Bits,exp)
        end
        function testGrowBitmask(testCase)
            
            import DataKit.bitmask
            
          	Ain = uint8([...
                17    24     5
                 4     8    20]);
             
            bm = bitmask(Ain);
            
            act = bm.setBit(3,1,8);
            exp = cat(2,Ain,[0;4]);
            
            testCase.verifyEqual(act.Bits,exp)
        end
        function testGrowBitmaskNewDim(testCase)
            
            import DataKit.bitmask
            
          	Ain = uint8([...
                17    24     5
                 4     8    20]);
             
            bm = bitmask(Ain);
            
            act = bm.setBit(3,1,1,2,3);
            exp = cat(3,Ain,zeros(size(Ain)));
            exp(1,2,3) = 4;
            
            testCase.verifyEqual(act.Bits,exp)
        end
	end
end