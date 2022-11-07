classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) subsref_test < matlab.unittest.TestCase
    % subsref_test  Unittests for DataKit.dataStore.subsref
    % This class holds the unittests for the DataKit.dataStore.subsref method.
    %
    % It can be run with runtests('Tests.DataKit.dataStore.subsref_test').
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
        function testSetRef01(testCase)
        % Test pattern: obj{1}

            actual      = testCase.DataStoreInstance{1};
            expected	= testCase.SetupData1;
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetRef02(testCase)
        % Test pattern: obj{1:2}

            actual      = {testCase.DataStoreInstance{1:2}};
            expected	= {testCase.SetupData1,testCase.SetupData2};
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetRef03(testCase)
        % Test pattern: obj{[1,3]}

            actual      = {testCase.DataStoreInstance{[1,3]}};
            expected	= {testCase.SetupData1,testCase.SetupData3};
            
            testCase.verifyEqual(actual,expected);
        end
        %{
        function testSetRef04(testCase)
        % Test pattern: obj{:}

            actual      = {testCase.DataStoreInstance{:}};
            expected	= {testCase.SetupData1,testCase.SetupData2,testCase.SetupData3};
            
            testCase.verifyEqual(actual,expected);
        end
        %}
        
        
        function testVariableRef01(testCase)
        % Test pattern: obj{1}(1)

            actual      = testCase.DataStoreInstance{1}(1);
            expected	= testCase.SetupData1(:,1);
            
            testCase.verifyEqual(actual,expected);
        end
        function testVariableRef02(testCase)
        % Test pattern: obj{1}(1:2)

            actual      = testCase.DataStoreInstance{1}(1:2);
            expected	= testCase.SetupData1(:,1:2);
            
            testCase.verifyEqual(actual,expected);
        end
        function testVariableRef03(testCase)
        % Test pattern: obj{2}([3,5])

            actual      = testCase.DataStoreInstance{2}([3,5]);
            expected	= testCase.SetupData2(:,[3,5]);
            
            testCase.verifyEqual(actual,expected);
        end
        function testVariableRef04(testCase)
        % Test pattern: obj{2}(:)

            actual      = testCase.DataStoreInstance{2}(:);
            expected	= testCase.SetupData2(:,:);
            
            testCase.verifyEqual(actual,expected);
        end
        function testVariableRef05(testCase)
        % Test pattern: obj{2}([5,3])

            actual      = testCase.DataStoreInstance{2}([5,3]);
            expected	= testCase.SetupData2(:,[5,3]);
            
            testCase.verifyEqual(actual,expected);
        end
        
        
        function testSetChunkRef01(testCase)
        % Test pattern: obj{2}(2,3)

            actual      = testCase.DataStoreInstance{2}(2,3);
            expected	= testCase.SetupData2(2,3);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef02(testCase)
        % Test pattern: obj{2}(2:5,3)

            actual      = testCase.DataStoreInstance{2}(2:5,3);
            expected	= testCase.SetupData2(2:5,3);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef03(testCase)
        % Test pattern: obj{2}(2,3:4)

            actual      = testCase.DataStoreInstance{2}(2,3:4);
            expected	= testCase.SetupData2(2,3:4);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef04(testCase)
        % Test pattern: obj{2}(2:3,3:4)

            actual      = testCase.DataStoreInstance{2}(2:3,3:4);
            expected	= testCase.SetupData2(2:3,3:4);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef05(testCase)
        % Test pattern: obj{2}([2,4],[1,5])

            actual      = testCase.DataStoreInstance{2}([2,4],[1,5]);
            expected	= testCase.SetupData2([2,4],[1,5]);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef06(testCase)
        % Test pattern: obj{2}(:,[1,5])

            actual      = testCase.DataStoreInstance{2}(:,[1,5]);
            expected	= testCase.SetupData2(:,[1,5]);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef07(testCase)
        % Test pattern: obj{2}([2,4],:)

            actual      = testCase.DataStoreInstance{2}([2,4],:);
            expected	= testCase.SetupData2([2,4],:);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef08(testCase)
        % Test pattern: obj{2}(:,:)

            actual      = testCase.DataStoreInstance{2}(:,:);
            expected	= testCase.SetupData2(:,:);
            
            testCase.verifyEqual(actual,expected);
        end
        function testSetChunkRef09(testCase)
        % Test pattern: obj{2}([4,3,1],[5,1])

            actual      = testCase.DataStoreInstance{2}([4,3,1],[5,1]);
            expected	= testCase.SetupData2([4,3,1],[5,1]);
            
            testCase.verifyEqual(actual,expected);
        end
	end
end
