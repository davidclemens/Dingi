classdef testDataPoolClass < matlab.unittest.TestCase
    
    properties
        DataPoolInstance
        NIndependantVariables
        NDependantVariables
    end
    
    properties (MethodSetupParameter)
        % Creates data pools with a single (s) or multiple (m),
        % independant (I) or dependant (D) variables.
        Data	= struct('IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1)),...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1)),...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1),randn(16000,1)),...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDm',            struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1),randn(16000,1)),...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                        )
    end
    properties (TestParameter)
        RequestedVariables  = struct('Ds',  {{'Oxygen'}},...
                                     'Dm',  {{'Nitrate','Oxygen'}})
    end
    
    methods (TestClassSetup)
        function addDataPoolClassToPath(testCase)
            pathOld = path;
            testCase.addTeardown(@path,pathOld)
            addpath('/Users/David/Dropbox/David/Syncing/MATLAB/toolboxes/')
        end
    end
    
    methods (TestMethodSetup)
        function setExpectedOutputs(testCase,Data)
            testCase.NIndependantVariables  = sum(ismember(Data.VariableType,'Independant'));
            testCase.NDependantVariables    = sum(ismember(Data.VariableType,'Dependant'));
        end
        function createDataPool(testCase,Data)
       	% Create a data pool before every test is run
            dp = DataKit.dataPool();
            dp = dp.addPool();
            pool = dp.PoolCount;
            dp = dp.addVariable(pool,Data.Variable,Data.Data,[],...
                    'VariableType',     Data.VariableType);
                
                
            testCase.DataPoolInstance = dp;
        end
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test, ParameterCombination = 'sequential')
        function testGetData(testCase,RequestedVariables)
            dp = testCase.DataPoolInstance;
            
            nRequestedVariables = numel(RequestedVariables);
            if nRequestedVariables > testCase.NDependantVariables
                % if more variables are requested than there are in the
                % data pool make sure it throws the approprieat error
                testCase.verifyError(@() getData(dp,RequestedVariables),'DataKit:dataPool:gd:unavailableVariableRequested')
            else
                data        = getData(dp,RequestedVariables);

                actNIndepVars       = numel(data.IndependantInfo.Variable);
                expNIndepVars       = testCase.NIndependantVariables;
                actNDepVars         = numel(data.DependantInfo.Variable);
                expNDepVars         = nRequestedVariables;
                testCase.verifyEqual(actNIndepVars,expNIndepVars)
                testCase.verifyEqual(actNDepVars,expNDepVars)
            end
        end
    end
end