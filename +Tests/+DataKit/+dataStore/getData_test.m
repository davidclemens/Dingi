classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) getData_test < matlab.unittest.TestCase
    % getData_test  Unittests for DataKit.dataStore.getData
    % This class holds the unittests for the DataKit.dataStore.getData method.
    %
    % It can be run with runtests('Tests.DataKit.dataStore.getData_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %

    properties
        DataStoreInstance
        TestCaseData
        TestCaseType
    end
    properties (ClassSetupParameter)

    end
    properties (MethodSetupParameter)
        % Creates dataStores in the TestMethodSetup
        SetupData1	= struct(...
            'scalar',           single(2),...
            'column',           single((1:100)'),...
            'array',            single((1:100)'.*[1,sin(1),cos(1)]))
        SetupData2	= struct(...
            'scalar',           single(3),...
            'column',           single((50:80)'),...
            'array',            single((50:80)'.*[1,sin(2),cos(2)]))
        Types = struct(...
            'single',           'single',...
            'double',           'double')
    end
    properties (TestParameter)
        SetId = struct(...
            'scalar_scalar',    {{1,3}},...
            'scalar_vector',    {{2,[2,3]}},...
            'vector_scalar',    {{1:2,1}},...
            'vector_vector',    {{1:2,1:2}})
        GroupMode = struct(...
            'NaN',      'NaN',...
            'Cell',     'Cell')
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        function createDataStore(testCase,SetupData1,SetupData2,Types)
       	% Create a dataStore before every test is run

            import DataKit.dataStore

            % Create dataStore
            testCase.DataStoreInstance      = dataStore(SetupData1,Types);
            testCase.DataStoreInstance.addDataAsNewSet(SetupData2);
            
            testCase.TestCaseData           = {SetupData1,SetupData2};
            testCase.TestCaseType           = Types;

            testCase.addTeardown(@delete,testCase.DataStoreInstance)
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testNoDataInput(testCase)
        % Test getData with no inputs

            testCase.verifyError(@() testCase.DataStoreInstance.getData(),'MATLAB:narginchk:notEnoughInputs');
        end

        function testValidDataInput(testCase,SetId,GroupMode)
            
            import UtilityKit.Utilities.arrayhom
            
            ds = testCase.DataStoreInstance;
            
            [setId,variableId] = arrayhom(SetId{:});
            
            im = ismember(cat(2,setId,variableId),ds.IndexVariables{:,{'SetId','VariableId'}},'rows');

            if any(~im)
                testCase.verifyError(@() testCase.DataStoreInstance.getData(SetId{1},SetId{2},GroupMode),'Dingi:DataKit:dataStore:validateVariableId:invalidVariableId');
            else
                % Calculate expected metadata
                dataExp = testCase.TestCaseData;
                
                % The output type is either double or single, depending on the storage type of
                % the dataStore.
                dataExp = cellfun(@(d) cast(d,ds.Type),dataExp,'un',0);
                switch GroupMode
                    case 'NaN'
                        dataExp = arrayfun(@(s,v) reshape(cat(1,dataExp{s}(:,v),NaN(1,1,testCase.TestCaseType)),[],1),setId,variableId,'un',0);
                        dataExp = cat(1,dataExp{:});
                        dataExp = dataExp(1:end - 1);
                    case 'Cell'
                        dataExp = arrayfun(@(s,v) reshape(dataExp{s}(:,v),[],1),setId,variableId,'un',0);
                end
                
                % Call getData
                dataAct = ds.getData(SetId{1},SetId{2},GroupMode);

                testCase.verifyEqual(dataAct,dataExp)
            end
        end
	end
end
