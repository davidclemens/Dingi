classdef testDataPoolFetchData < matlab.unittest.TestCase
    
    % run:
    % suite = matlab.unittest.TestSuite.fromClass(?UnitTests.testDataPoolFetchData);
    % run(suite)
    
    properties
        DataPoolInstance
        IndependantVariables
        DependantVariables
        NIndependantVariables
        NDependantVariables
        NData
    end
    
    properties (MethodSetupParameter)
        % Creates data pools with a single (s) or multiple (m),
        % independant (I) or dependant (D) variables.
        Data1	= struct('IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDm',            struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                        )
        Data2	= struct('IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',reshape(repmat(0:30,1000,1),[],1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',randn(31000,1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDm',            struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',reshape(repmat(0:30,1000,1),[],1),randn(31000,1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                        )
    end
    properties (TestParameter)
        RequestedVariables  = struct('none',[],...
                                     'Ds',  {{'Oxygen'}},...
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
        function setExpectedOutputs(testCase,Data1,Data2)
            tmpVars     = cat(2,Data1.Variable,Data2.Variable);
            tmpVarType  = cat(2,Data1.VariableType,Data2.VariableType);
            testCase.NData	= cat(2,size(Data1.Data,1),size(Data2.Data,1));
            
            testCase.IndependantVariables	= unique(tmpVars(ismember(tmpVarType,'Independant')));
            testCase.DependantVariables     = unique(tmpVars(ismember(tmpVarType,'Dependant')));
            
            testCase.NIndependantVariables	= numel(testCase.IndependantVariables);
            testCase.NDependantVariables    = numel(testCase.DependantVariables);
        end
        function createDataPool(testCase,Data1,Data2)
       	% Create a data pool before every test is run
            dp      = DataKit.dataPool();
            dp      = dp.addPool();
            pool    = dp.PoolCount;
            dp      = dp.addVariable(pool,Data1.Variable,Data1.Data,[],...
                        'VariableType',     Data1.VariableType,...
                        'VariableOrigin',   Data1.VariableOrigin);
                    
            % Add second pool
            dp      = dp.addPool();
            pool    = dp.PoolCount;
            dp      = dp.addVariable(pool,Data2.Variable,Data2.Data,[],...
                        'VariableType',     Data2.VariableType,...
                        'VariableOrigin',   Data2.VariableOrigin);
                
            testCase.DataPoolInstance = dp;
        end
    end
    methods (TestMethodTeardown)
        
    end
    
    methods (Test, ParameterCombination = 'sequential')
%         function testFetchDataWarning(testCase,RequestedVariables)
%             
%             nRequestedVariables = numel(RequestedVariables);
%             if any(nRequestedVariables <= testCase.NDependantVariables)
%                 return
%             else
%                 testCase.verifyWarning(@() ...
%                     fetchData(testCase.DataPoolInstance,RequestedVariables,...
%                             'ForceCellOutput',      true),...
%                     'DataKit:dataPool:fetchData:requestedVariableIsUnavailable')
%             end
%         end
        function testFetchDataReturnStructNIndependantVariables(testCase,RequestedVariables)
            
            nRequestedVariables = numel(RequestedVariables);
            if any(nRequestedVariables <= testCase.NDependantVariables)

                data	= fetchData(testCase.DataPoolInstance,RequestedVariables,...
                            'ForceCellOutput',      true);
            else
                % tested elswhere
                return
            end
            
            % number of independant variables returned
            act  	= cellfun(@(x) size(x,2),data.IndepData,'un',1);
            exp   	= repmat(testCase.NIndependantVariables,1,testCase.NDependantVariables);
            testCase.verifyTrue(all(act == exp))
        end
        function testFetchDataReturnStructNDependantVariables(testCase,RequestedVariables)
            
            nRequestedVariables = numel(RequestedVariables);
            if any(nRequestedVariables <= testCase.NDependantVariables)

                data	= fetchData(testCase.DataPoolInstance,RequestedVariables,...
                            'ForceCellOutput',      true);
            else
                return
            end
            % number of dependant variables returned
            act 	= numel(data.DepData);
            if nRequestedVariables == 0
                % if no variable is supplied, all available are
                % returned
                exp = testCase.NDependantVariables;
            else
                exp  	= nRequestedVariables;
            end
            testCase.verifyEqual(act,exp)
        end
    end
end