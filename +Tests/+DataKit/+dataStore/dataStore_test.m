classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) dataStore_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.dataStore.dataStore_test);
    % run(tests)

    properties
        
    end
    properties (ClassSetupParameter)

    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        % Add the new data to an existing or a new dataStore
        Data = struct(...
            'scalar',           single(2),...
            'column',           single((1:100)'),...
            'array',            single((1:100)'.*[1,sin(1),cos(1)]))
        Type = struct(...
            'double',       'double',...
            'single',       'single')
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testNoDataInput(testCase)
        % Test dataStore with no inputs

            % Calculate expected metadata
            nSamplesExp     = 0;
            nSetsExp        = 0;
            nVariablesExp   = 0;
            
            % Call dataStore
            ds = DataKit.dataStore();
            
            % Get actual values
            nSamplesAct     = ds.NSamples;
            nSetsAct        = ds.NSets;
            nVariablesAct   = ds.NVariables;
            
            % Run tests
            testCase.verifyEqual(nSamplesAct,nSamplesExp)
            testCase.verifyEqual(nSetsAct,nSetsExp)
            testCase.verifyEqual(nVariablesAct,nVariablesExp)
        end
        function testEmptyDataInput(testCase)
        % Test dataStore with empty data ipnut

            testCase.verifyError(@() DataKit.dataStore([]),'MATLAB:addDataAsNewSet:expectedNonempty');
        end
        function testInvalidTypeInput(testCase)
        % Test dataStore with valid data but invalid type inputs

            testCase.verifyError(@() DataKit.dataStore(1:3,3),'MATLAB:setType:unrecognizedStringChoice');
        end
        function testValidDataInput(testCase,Data,Type)

            % Calculate expected metadata
            typeExp         = Type;
            nSamplesExp     = numel(Data);
            nSetsExp        = 1;
            nVariablesExp   = size(Data,2);
            
            % Call dataStore
            ds = DataKit.dataStore(Data,Type);
            
            % Get actual values
            typeAct         = ds.Type;
            nSamplesAct     = ds.NSamples;
            nSetsAct        = ds.NSets;
            nVariablesAct   = ds.NVariables;
            
            % Run tests
            testCase.verifyEqual(typeAct,typeExp)
            testCase.verifyEqual(nSamplesAct,nSamplesExp)
            testCase.verifyEqual(nSetsAct,nSetsExp)
            testCase.verifyEqual(nVariablesAct,nVariablesExp)
        end
	end
end
