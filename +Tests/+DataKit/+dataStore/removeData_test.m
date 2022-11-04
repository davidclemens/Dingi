classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) removeData_test < matlab.unittest.TestCase
    % removeData_test  Unittests for DataKit.dataStore.removeData
    % This class holds the unittests for the DataKit.dataStore.removeData method.
    %
    % It can be run with runtests('Tests.DataKit.dataStore.removeData_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %

    properties
        DataStoreInstance
        SetLengths
        SetNVariables
        SetupData1 = single((1:10)'.*[1,sin(1),cos(1),1]);
        SetupData2 = single((1:15)'.*[1,sin(1),cos(1),3,4,5,6]);
        SetupData3 = single((1:12)'.*[1,sin(1),cos(1),3,4]);
    end
    properties (ClassSetupParameter)

    end
    properties (MethodSetupParameter)
        
    end
    properties (TestParameter)
        
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        function createDataStore(testCase)
       	% Create a dataStore before every test is run

            import DataKit.dataStore
            
            % Create dataStore
            testCase.DataStoreInstance      = dataStore(testCase.SetupData1);
            
            % Add data
            testCase.DataStoreInstance.addDataAsNewSet(testCase.SetupData2);
            testCase.DataStoreInstance.addDataAsNewSet(testCase.SetupData3);
            
            % Store shapes
            testCase.SetLengths = [...
                size(testCase.SetupData1,1),...
                size(testCase.SetupData2,1),...
                size(testCase.SetupData3,1)];
            testCase.SetNVariables = [...
                size(testCase.SetupData1,2),...
                size(testCase.SetupData2,2),...
                size(testCase.SetupData3,2)];

            testCase.addTeardown(@delete,testCase.DataStoreInstance)
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testRemoveEntireSetFromStart(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 1;
            variableId = 1:testCase.SetNVariables(setId);
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {testCase.SetupData2;testCase.SetupData3};
            
            testCase.verifyEqual(actual,expected)
        end
        function testRemoveEntireSetFromEnd(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 3;
            variableId = 1:testCase.SetNVariables(setId);
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {testCase.SetupData1;testCase.SetupData2};
            
            testCase.verifyEqual(actual,expected)
        end
        function testRemoveEntireSetFromMiddle(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 2;
            variableId = 1:testCase.SetNVariables(setId);
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {testCase.SetupData1;testCase.SetupData3};
            
            testCase.verifyEqual(actual,expected)
        end
        function testRemoveVariableFromStartOfSet(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 1:3;
            variableId = 1;
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {...
                testCase.SetupData1(:,2:end);...
                testCase.SetupData2(:,2:end);...
                testCase.SetupData3(:,2:end)};
            
            testCase.verifyEqual(actual,expected)
        end
        function testRemoveVariableFromMiddleOfSet(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 1:3;
            variableId = 3;
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {...
                testCase.SetupData1(:,[1:2,4:end]);...
                testCase.SetupData2(:,[1:2,4:end]);...
                testCase.SetupData3(:,[1:2,4:end])};
            
            testCase.verifyEqual(actual,expected)
        end
        function testRemoveVariableFromEndOfSet(testCase)

            ds = testCase.DataStoreInstance;
            
            setId = 1:3;
            variableId = testCase.SetNVariables;
            
            ds.removeData(setId,variableId);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {...
                testCase.SetupData1(:,1:end - 1);...
                testCase.SetupData2(:,1:end - 1);...
                testCase.SetupData3(:,1:end - 1)};
            
            testCase.verifyEqual(actual,expected)
        end
        function testDataIO(testCase)

            ds = testCase.DataStoreInstance;
            
            ds.removeData(1:3,1);
            ds.addDataToExistingSet(2,testCase.SetupData2);
            ds.removeData(3,2);
            
            actual = ds.getData(ds.IndexVariables{:,'SetId'},ds.IndexVariables{:,'VariableId'},'CellBySet');
            expected = {...
                testCase.SetupData1(:,2:end);...
                [testCase.SetupData2(:,2:end),testCase.SetupData2];...
                testCase.SetupData3(:,[2,4:end])};
            
            testCase.verifyEqual(actual,expected)
        end
	end
end
