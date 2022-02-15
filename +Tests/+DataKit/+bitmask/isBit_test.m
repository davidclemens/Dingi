classdef (SharedTestFixtures = { matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'}))) }) isBit_test < matlab.unittest.TestCase
	% setNum_test  Tests bitmask.isBit behaviour
    % The ISBIT_TEST test class tests the functionality of the
    % DataKit.bitmask.isBit method.
    %
    % Run the tests: 
    %   Run and stop if verification fails:
    %     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.isBit_test);
    %     runner    = matlab.unittest.TestRunner.withTextOutput;
    %     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
    %     runner.run(tests)
    %   Run:
    %     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.bitmask.isBit_test);
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
        function testBitGreaterThanMaxStorageType(testCase)
            act = isBit(testCase.obj,66);
            exp = false(testCase.obj.Size);
            
            testCase.verifyEqual(act,exp);
        end
        function testBitGreaterThanStorageType(testCase)
            act = isBit(testCase.obj,9);
            exp = false(testCase.obj.Size);
            
            testCase.verifyEqual(act,exp);
        end
        function testBitSmallerThanStorageType(testCase)
            act = isBit(testCase.obj,4);
            exp = logical([...
                    0   1   0
                    0   1   0]);
            
            testCase.verifyEqual(act,exp);
        end
	end
end