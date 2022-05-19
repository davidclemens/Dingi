classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) addDataAsNewSet_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.dataStore.addDataAsNewSet_test);
    % run(tests)

    properties
        DataStoreInstance
    end
    properties (ClassSetupParameter)

    end
    properties (MethodSetupParameter)
        % Creates dataStores in the TestMethodSetup
        SetupData	= struct(...
            'scalar',           single(2),...
            'column',           single((1:100)'),...
            'array',            single((1:100)'.*[1,sin(1),cos(1)]))
    end
    properties (TestParameter)
        % Add the new data to an existing or a new dataStore
        NewData	= struct(...
            'scalar',           single(2),...
            'column',           single((1:100)'),...
            'array',            single((1:100)'.*[1,sin(1),cos(1)]))
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        function createDataStore(testCase,SetupData)
       	% Create a dataStore before every test is run

            import DataKit.dataStore

            % Create dataStore
            testCase.DataStoreInstance = dataStore(SetupData);

            testCase.addTeardown(@delete,testCase.DataStoreInstance)
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testNoDataInput(testCase)
        % Test addDataAsNewSet with no inputs

            testCase.verifyError(@() testCase.DataStoreInstance.addDataAsNewSet(),'MATLAB:narginchk:notEnoughInputs');
        end
        function testEmptyDataInput(testCase)
        % Test addDataAsNewSet with empty data

            testCase.verifyError(@() testCase.DataStoreInstance.addDataAsNewSet([]),'MATLAB:addDataAsNewSet:expectedNonempty');
        end
        function testValidDataInput(testCase,NewData)

            ds = testCase.DataStoreInstance;

            % Calculate expected metadata
            nSamplesExp     = ds.NSamples + numel(NewData);
            nSetsExp        = ds.NSets + 1;
            nVariablesExp   = ds.NVariables + size(NewData,2);
            
            % Call addVariable
            ds.addDataAsNewSet(NewData)
            
            % Get actual values
            nSamplesAct     = ds.NSamples;
            nSetsAct        = ds.NSets;
            nVariablesAct   = ds.NVariables;
            
            % Run tests
            testCase.verifyEqual(nSamplesAct,nSamplesExp)
            testCase.verifyEqual(nSetsAct,nSetsExp)
            testCase.verifyEqual(nVariablesAct,nVariablesExp)
        end
	end
end
