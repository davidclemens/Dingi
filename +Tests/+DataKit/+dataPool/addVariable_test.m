classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) addVariable_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.DataKit.dataPool.addVariable_test);
    % run(tests)

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
        SetupData	= struct(...
                             ... % start with an empty dataPool
                             'empty',           struct('Variable',          {{}},...
                                                       'Data',              [],...
                                                       'VariableOrigin',    {{}},...
                                                       'VariableType',      {{}}),...
                             ... % start with a 16000x2 dataPool
                             'IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                       'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1)),...
                                                       'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                       'VariableType',      {{'Independant','Dependant'}}),...
                             ... % start with a 16000x3 dataPool
                             'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                       'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1)),...
                                                       'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                       'VariableType',      {{'Independant','Independant','Dependant'}}),...
                             ... % start with a 16000x3 dataPool
                             'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                       'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1),randn(16000,1)),...
                                                       'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                       'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                             'ImDm',            struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                             ... % start with a 16000x4 dataPool
                                                       'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1),randn(16000,1)),...
                                                       'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                       'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                            )
    end
    properties (TestParameter)
        % Add the new data to an existing or a new data pool
        PoolIdx = struct(...
                         'existing',        1,...
                         'new',             2,...
                         'newLarge',        5)
        % Creates data pools with a single (s) or multiple (m),
        % independant (I) or dependant (D) variables and sample sizes
        % equal (Eq), greater than (Gt) or less than (Lt) the existing
        % ones.
        NewData = struct(...
                         'IsDsEq',          struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDsEq',          struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDmEq',          struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDmEq',          struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}}),...
                         'IsDsGt',          struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,18000)',randn(18000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDsGt',          struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,18000)',reshape(repmat(0:17,1000,1),[],1),randn(18000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDmGt',          struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,18000)',randn(18000,1),randn(18000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDmGt',          struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,18000)',reshape(repmat(0:17,1000,1),[],1),randn(18000,1),randn(18000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}}),...
                         'IsDsLt',          struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,10000)',randn(10000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independant','Dependant'}}),...
                         'ImDsLt',          struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,10000)',reshape(repmat(0:9,1000,1),[],1),randn(10000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant'}}),...
                         'IsDmLt',          struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,10000)',randn(10000,1),randn(10000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independant','Dependant','Dependant'}}),...
                         'ImDmLt',          struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,10000)',reshape(repmat(0:9,1000,1),[],1),randn(10000,1),randn(10000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                        )
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        function createDataPool(testCase,SetupData)
       	% Create a data pool before every test is run
            dp      = DataKit.dataPool();
            if ~isempty(SetupData.Data)
                dp      = dp.addPool();
                pool    = dp.PoolCount;
                dp      = dp.addVariable(pool,SetupData.Variable,SetupData.Data,[],...
                            'VariableType',     SetupData.VariableType,...
                            'VariableOrigin',   SetupData.VariableOrigin);
            end
            testCase.DataPoolInstance = dp;
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)
        function testDataErrorsAndWarnings(testCase,PoolIdx,NewData)

            dp      = testCase.DataPoolInstance;

            pool      	= PoolIdx;
            nSamplesNew	= size(NewData.Data,1);
            if PoolIdx > dp.PoolCount
                nSamplesExisting = 0;
            else
                nSamplesExisting = size(dp.DataRaw{pool},1);
            end

            if nSamplesExisting > 0 && nSamplesNew ~= nSamplesExisting
                % Case: variable to add has a different number of samples
                % than the existing variables in the pool.

                testCase.verifyError(@() ...
                dp.addVariable(pool,NewData.Variable,NewData.Data,[],...
                    'VariableType',     NewData.VariableType,...
                    'VariableOrigin',   NewData.VariableOrigin),...
                'Dingi:DataKit:dataPool:addVariable:invalidNumberOfSamples')
            end
        end
        function testAddVariable(testCase,PoolIdx,NewData)

            dp      = testCase.DataPoolInstance;

            pool                        = PoolIdx;
            [nSamplesNew,nVariablesNew] = size(NewData.Data);
            if PoolIdx > dp.PoolCount
                nSamplesExisting    = 0;
                nVariablesExisting  = 0;
            else
                [nSamplesExisting,nVariablesExisting] = size(dp.DataRaw{pool});
            end

            if nSamplesExisting > 0 && nSamplesNew ~= nSamplesExisting
                % Case: variable to add has a different number of samples
                % than the existing variables in the pool. Handled in
                % 'testDataErrorsAndWarnings'.
                return
            end

            dp      = dp.addVariable(pool,NewData.Variable,NewData.Data,[],...
                        'VariableType',     NewData.VariableType,...
                        'VariableOrigin',   NewData.VariableOrigin);

            pool   = min([PoolIdx,dp.PoolCount]);
            % Subtest 01: number of variables added
            act  	= size(dp.DataRaw{pool},2);
            exp   	= nVariablesExisting + nVariablesNew;
            testCase.verifyEqual(act,exp)

            % Subtest 02: number of samples added
            act  	= size(dp.DataRaw{pool},1);
            exp   	= nSamplesNew;
            testCase.verifyEqual(act,exp)

            % Subtest 03: variable names
            act  	= cellstr(dp.Info(pool).Variable(nVariablesExisting + 1:end));
            exp   	= NewData.Variable;
            testCase.verifyEqual(act,exp)

            % Subtest 04: variable type
            act  	= cellstr(dp.Info(pool).VariableType(nVariablesExisting + 1:end));
            exp   	= NewData.VariableType;
            testCase.verifyEqual(act,exp)

            % Subtest 05: variable origin
            act  	= dp.Info(pool).VariableOrigin(nVariablesExisting + 1:end);
            exp   	= NewData.VariableOrigin;
            passed  = cellfun(@(a,b) isequal(a,b),act,exp);
            testCase.verifyTrue(all(passed))
        end
	end
end
