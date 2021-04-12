classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) fetchData_test < matlab.unittest.TestCase

    % run:
    % tests = matlab.unittest.TestSuite.fromClass(?Tests.GearKit.gearDeployment.fetchData_test);
    % run(tests)

    properties
        GearDeploymentInstance
        IndependantVariables
        DependantVariables
        NIndependantVariables
        NDependantVariables
        NData
        NExpectedVariables
        NExpectedGroups
        NDataPools
        NMeasuringDevices
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
                         'ImDm',            struct('Variable',          {{'Time','Z','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',reshape(repmat(0:30,1000,1),[],1),randn(31000,1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independant','Independant','Dependant','Dependant'}})...
                        )
    end
    properties (TestParameter)
        RequestedVariables      = struct('none',    [],...
                                         'Ds',      {{'Oxygen'}},...
                                         'Dm',      {{'Nitrate','Oxygen'}},...
                                         'invalid', {{'Temperature'}})
        xDataOnly               = struct('none',    [false false],...
                                         'DeplT',   [true false],...
                                         'ToI',     [false true])
        RelativeTime            = struct('none',    [],...
                                         'ms',      'ms',...
                                         's',       's',...
                                         'min',     'm',...
                                         'h',       'h',...
                                         'd',       'd',...
                                         'y',       'y',...
                                         'dt',      'datetime',...
                                         'dn',      'datenum',...
                                         'invalid', 'invalid')
        GroupBy                 = struct('none',    '',...
                                         'Var',     'Variable',...
                                         'Md',   	'MeasuringDevice')
    end

    methods (TestClassSetup)

    end
    methods (TestMethodSetup)
        function setExpectedOutputs(testCase,Data1,Data2)
            tmpVars         = cat(2,Data1.Variable,Data2.Variable);
            tmpVarType      = cat(2,Data1.VariableType,Data2.VariableType);
            testCase.NData	= cat(2,size(Data1.Data,1),size(Data2.Data,1));

            testCase.IndependantVariables	= unique(tmpVars(ismember(tmpVarType,'Independant')));
            testCase.DependantVariables     = unique(tmpVars(ismember(tmpVarType,'Dependant')));

            testCase.NIndependantVariables	= numel(testCase.IndependantVariables);
            testCase.NDependantVariables    = numel(testCase.DependantVariables);
        end
        function createGearDeployment(testCase,Data1,Data2)
            % Create a data pool before every test is run
            dp      = DataKit.dataPool();
            dp      = dp.addVariable(Data1.Variable,Data1.Data,...
                        'VariableType',     Data1.VariableType,...
                        'VariableOrigin',   Data1.VariableOrigin);

            % Add second pool
            dp      = dp.addVariable(Data2.Variable,Data2.Data,...
                        'VariableType',     Data2.VariableType,...
                        'VariableOrigin',   Data2.VariableOrigin);


            bigo        = GearKit.bigoDeployment;
            bigo.data   = dp;
            bigo.timeDeployment         = datetime(2020,10,2,15,42,50);
            bigo.timeOfInterestStart    = datetime(2020,10,2,15,52,50);
            bigo.timeOfInterestEnd      = datetime(2020,10,2,19,32,38);
            bigo.timeRecovery           = datetime(2020,10,2,19,42,38);

            testCase.GearDeploymentInstance = bigo;
        end
    end
    methods (TestMethodTeardown)

    end

    methods (Test)

        function testNVariables(testCase,RequestedVariables,xDataOnly,RelativeTime,GroupBy)

            dp      = testCase.GearDeploymentInstance.data;
            index   = dp.Index;

            nRequestedVariables = numel(RequestedVariables);
            if nRequestedVariables == 0
                RequestedVariables  = cellstr(unique(index{index{:,'VariableType'} == 'Dependant','Variable'}));
            end
            nRequestedVariables         = numel(RequestedVariables);
            testCase.NExpectedVariables	= nRequestedVariables;

            maskIndex = ismember(index{:,'Variable'},RequestedVariables);
            if sum(maskIndex) > 0
                switch GroupBy
                    case ''
                        testCase.NExpectedGroups    = 1;
                    case 'Variable'
                        testCase.NExpectedGroups    = numel(index{maskIndex,'DataPool'});
                    case 'MeasuringDevice'
                        testCase.NExpectedGroups    = numel(unique(index{maskIndex,'MeasuringDevice'}));
                    otherwise
                        error('Dingi:Tests:GearKit:gearDeployment:fetchData_test:invalidGroupBy',...
                          '''%s'' is an invalid ''GroupBy'' value.',GroupBy)
                end
            else
                testCase.NExpectedGroups = 1;
            end

            variableIsInDataPool = ismember(RequestedVariables,index{:,'Variable'});

            % Handle warnings and errors
            if isequal(testCase.RequestedVariables.invalid,RequestedVariables)
                % Case: none of the requested variables are available
                testCase.verifyWarning(@() ...
                    fetchData(testCase.GearDeploymentInstance,RequestedVariables,...
                            'DeploymentDataOnly',       xDataOnly(1),...
                            'TimeOfInterestDataOnly',   xDataOnly(2),...
                            'RelativeTime',             RelativeTime,...
                            'GroupBy',                  GroupBy),...
                    'Dingi:DataKit:dataPool:fetchData:noDataForRequestedInputsAvailable')
                return
            end
            if any(~variableIsInDataPool)
                % Case: at least one of the requested variables is
                % unavailable.
                testCase.verifyError(@() ...
                    fetchData(testCase.GearDeploymentInstance,RequestedVariables,...
                            'DeploymentDataOnly',       xDataOnly(1),...
                            'TimeOfInterestDataOnly',   xDataOnly(2),...
                            'RelativeTime',             RelativeTime,...
                            'GroupBy',                  GroupBy),...
                    'Dingi:DataKit:dataPool:fetchData:requestedVariableIsUnavailable')
                return
            end
            if strcmp(RelativeTime,'invalid')
                % Case: invalid relative time identifier.
                testCase.verifyError(@() ...
                    fetchData(testCase.GearDeploymentInstance,RequestedVariables,...
                            'DeploymentDataOnly',       xDataOnly(1),...
                            'TimeOfInterestDataOnly',   xDataOnly(2),...
                            'RelativeTime',             RelativeTime,...
                            'GroupBy',                  GroupBy),...
                    'Dingi:GearKit:gearDeployment:fetchData:unknownRelativeTimeIdentifier')
                return
            end
            if any(xDataOnly)

            end

            data	= fetchData(testCase.GearDeploymentInstance,RequestedVariables,...
                        'DeploymentDataOnly',       xDataOnly(1),...
                        'TimeOfInterestDataOnly',   xDataOnly(2),...
                        'RelativeTime',             RelativeTime,...
                        'GroupBy',                  GroupBy);

            % Subtest 01: number of variables returned
            act 	= size(data.DepData,2);
            exp     = testCase.NExpectedVariables;
            testCase.verifyEqual(act,exp)

            % Subtest 02: number of groups returned
            act 	= size(data.DepData,1);
            exp     = testCase.NExpectedGroups;
            testCase.verifyEqual(act,exp)
        end
	end
end
