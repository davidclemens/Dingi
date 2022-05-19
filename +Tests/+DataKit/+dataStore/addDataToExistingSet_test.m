classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) addDataToExistingSet_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.dataStore.addDataToExistingSet_test);
    % run(tests)

    properties
        DataStoreInstance
        TestCaseSetLength
        TestCaseSetNVariables
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
            
            testCase.TestCaseSetLength      = size(SetupData,1);
            testCase.TestCaseSetNVariables  = size(SetupData,2);

            testCase.addTeardown(@delete,testCase.DataStoreInstance)
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testNoDataInput(testCase)
        % Test addDataToExistingSet with no inputs

            testCase.verifyError(@() testCase.DataStoreInstance.addDataToExistingSet(),'MATLAB:narginchk:notEnoughInputs');
        end
        function testEmptyDataInput(testCase)
        % Test addDataToExistingSet with valid setId but empty data

            testCase.verifyError(@() testCase.DataStoreInstance.addDataToExistingSet(1,[]),'MATLAB:addDataToExistingSet:expectedNonempty');
        end
        function testEmptySetIdInput(testCase)
        % Test addDataToExistingSet with empty setId but valid data

            testCase.verifyError(@() testCase.DataStoreInstance.addDataToExistingSet([],1),'MATLAB:validateSetId:expectedVector');
        end
        function testValidDataInput(testCase,NewData)

            ds = testCase.DataStoreInstance;

            % Calculate expected metadata
            nSamplesExp     = ds.NSamples + numel(NewData);
            nSetsExp        = ds.NSets;
            nVariablesExp   = ds.NVariables + size(NewData,2);
            
            % Call addVariable
            newDataLength = size(NewData,1);
            
            if newDataLength ~= testCase.TestCaseSetLength
                % If the length of the new data does not agree with the destination set
                testCase.verifyError(@() testCase.DataStoreInstance.addDataToExistingSet(1,NewData),'Dingi:DataKit:dataStore:addDataToExistingSet:invalidDataLength');
            else
                ds.addDataToExistingSet(1,NewData)
                
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
end
