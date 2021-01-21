classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) sparseBitmask_test < matlab.unittest.TestCase
    
% run and stop if verification fails:
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.sparseBitmask.sparseBitmask_test);
%     runner    = matlab.unittest.TestRunner.withTextOutput;
%     runner.addPlugin(matlab.unittest.plugins.StopOnFailuresPlugin);
%     runner.run(tests)
% run :
%     tests     = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.Metadata.sparseBitmask.sparseBitmask_test);
%     run(tests)
    
    properties
        SparseBitmask
        ExpSize
        ExpBitmask
    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % Input parameters to test for the following input schemes:
        %     obj = sparseBitmask(A)
        %     obj = sparseBitmask(m,n)
        %     obj = sparseBitmask(i,j,bit)
        %     obj = sparseBitmask(i,j,bit,m,n)
        %
        % The naming convention for each test case is
        %     {inputParameter}_{shapeInput}_{inputValueMagnitude}
        % where
        %     shapeInput: S (scalar), V (vertical vector), H (horizontal
        %       vector), M1 (matrix long), M2 (matrix wide)
        %     inputValueMagnitude: U (unit), S (small), L (large)
        
        A   = struct(...
                         'A_S_U',       	1,...
                         'A_S_S',           6,...
                         'A_S_L',           50,...
                         'A_V_U',           ones(5,1),...
                         'A_V_S',           [4 5 5 9 3]',...
                         'A_V_L',           [52 43 50 49 45]',...
                         'A_H_U',           ones(1,5),...
                         'A_H_S',           [4 5 5 9 3],...
                         'A_H_L',           [52 43 50 49 45],...
                         'A_M1_U',          ones(7,5),...
                         'A_M1_S',          [9 3 9 3 10;4 2 3 7 5;4 9 6 6 10;8 8 4 6 1;1 6 8 10 2;6 5 1 4 2;8 4 6 2 3],...
                         'A_M1_L',          [43 29 42 2 35;48 50 8 45 9;7 51 22 49 37;48 9 48 36 2;33 51 42 40 15;6 50 50 39 3;15 26 35 21 6],...
                         'A_M2_U',          ones(5,7),...
                         'A_M2_S',          [9 3 9 3 10;4 2 3 7 5;4 9 6 6 10;8 8 4 6 1;1 6 8 10 2;6 5 1 4 2;8 4 6 2 3]',...
                         'A_M2_L',          [43 29 42 2 35;48 50 8 45 9;7 51 22 49 37;48 9 48 36 2;33 51 42 40 15;6 50 50 39 3;15 26 35 21 6]'...
                         )
        m   = struct(...
                         'm_U',             1,...
                         'm_S',             6,...
                         'm_L',             390193 ...
                     )
        n   = struct(...
                         'n_U',             1,...
                         'n_S',             3 ...
                         ...% skip to save memory 'n_L',             129400 ...
                         )
        i	= struct(...
                         'i_S_U',           1,...
                         'i_S_S',           5,...
                         'i_S_L',           403241,...
                         'i_V_U',           ones(5,1),...
                         'i_V_S',           [3 9 13 9 1]',...
                         'i_V_L',           149302.*[3 9 13 9 1]',...
                         'i_H_U',           ones(1,5),...
                         'i_H_S',           [3 9 13 9 1],...
                         'i_H_L',           149302.*[3 9 13 9 1],...
                         'i_M1_U',          ones(7,5),...
                         'i_M1_S',          [3 9 13 9 1].*[3 1 6 1 3 7 2]',...
                         'i_M1_L',          149302.*([3 5 9 1 2].*[3 1 6 1 3 7 2]'),...
                         'i_M2_U',          ones(5,7),...
                         'i_M2_S',          [3 9 13 9 1]'.*[3 1 6 1 3 7 2],...
                         'i_M2_L',          149302.*([3 5 9 1 2]'.*[3 1 6 1 3 7 2])...
                         )
        j	= struct(...
                         'j_S_U',           1,...
                         'j_S_S',           3,...
                         ...% skip to save memory 'j_S_L',           7163581,...
                         'j_V_U',           ones(5,1),...
                         'j_V_S',           [8 7 1 3 7]',...
                         ...% skip to save memory 'j_V_L',           3581001.*[8 7 1 3 2]',...
                         'j_H_U',           ones(1,5),...
                         'j_H_S',           [8 7 1 3 7],...
                         ...% skip to save memory 'j_H_L',           3581001.*[8 7 1 3 7],...
                         'j_M1_U',          ones(7,5),...
                         'j_M1_S',          [8 7 1 3 7].*[6 1 3 11 4 9 1]',...
                         ...% skip to save memory 'j_M1_L',          3581001.*([8 7 1 3 7].*[6 1 3 11 4 9 1]'),...
                         'j_M2_U',          ones(5,7),...
                         'j_M2_S',          [8 7 1 3 7]'.*[6 1 3 11 4 9 1]...
                         ...% skip to save memory j_M2_L',          3581001.*([8 7 1 3 7]'.*[6 1 3 11 4 9 1])...
                         )
        bit	= struct(...
                         'bit_S_U',       	1,...
                         'bit_S_S',         6,...
                         'bit_S_L',         50,...
                         'bit_V_U',         ones(5,1),...
                         'bit_V_S',         [4 5 5 9 3]',...
                         'bit_V_L',         [52 43 50 49 45]',...
                         'bit_H_U',         ones(1,5),...
                         'bit_H_S',         [4 5 5 9 3],...
                         'bit_H_L',         [52 43 50 49 45],...
                         'bit_M1_U',        ones(7,5),...
                         'bit_M1_S',        [9 3 9 3 10;4 2 3 7 5;4 9 6 6 10;8 8 4 6 1;1 6 8 10 2;6 5 1 4 2;8 4 6 2 3],...
                         'bit_M1_L',        [43 29 42 2 35;48 50 8 45 9;7 51 22 49 37;48 9 48 36 2;33 51 42 40 15;6 50 50 39 3;15 26 35 21 6],...
                         'bit_M2_U',        ones(5,7),...
                         'bit_M2_S',        [9 3 9 3 10;4 2 3 7 5;4 9 6 6 10;8 8 4 6 1;1 6 8 10 2;6 5 1 4 2;8 4 6 2 3]',...
                         'bit_M2_L',        [43 29 42 2 35;48 50 8 45 9;7 51 22 49 37;48 9 48 36 2;33 51 42 40 15;6 50 50 39 3;15 26 35 21 6]'...
                         )
    end
    
    methods (TestClassSetup)
        
    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)
    end
    
    methods (Test)
        function checkBitmaskInputCaseA(testCase,A)
            import DataKit.Metadata.sparseBitmask
            
            sb          = sparseBitmask(A);
            expSize     = size(A);
            
            % Test 01: check size
            act     = size(sb);
            exp     = expSize;
            testCase.verifyEqual(act,exp);
        end
        function checkBitmaskInputCaseB(testCase,m,n)
            import DataKit.Metadata.sparseBitmask
            
            sb          = sparseBitmask(m,n);
            expSize     = cat(2,m,n);
            
            % Test 01: check size
            act     = size(sb);
            exp     = expSize;
            testCase.verifyEqual(act,exp);
        end
        function checkBitmaskInputCaseC(testCase,i,j,bit)
            import DataKit.Metadata.sparseBitmask
            
            try
                sb	= sparseBitmask(i,j,bit);
            catch ME
                switch ME.identifier
                    case 'DataKit:arrayhom:invalidNumberOfSingletonDimensions'
                        return
                    otherwise
                        rethrow(ME)
                end
            end
            
            expSize     = cat(2,max(i(:)),max(j(:)));
            
            % Test 01: check size
            act     = size(sb);
            exp     = expSize;
            testCase.verifyEqual(act,exp);
        end
	end
end