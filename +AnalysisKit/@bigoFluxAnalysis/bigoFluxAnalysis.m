classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS


    properties (SetObservable, AbortSet)
        Name char = 'BigoFlux' % Analysis name
        Type char = 'Flux' % Analysis type
        Parent = GearKit.bigoDeployment % Parent bigoDeployment instance
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed

        TimeUnit (1,:) char = 'h' % The relative time unit

        FitType (1,:) char {mustBeMember(FitType,{'linear','poly1','poly2','poly3'})} = 'linear' % Fit method
        FitInterval (1,2) duration = hours([0,5]) % The interval that should be fitted to
        FitEvaluationInterval (1,2) duration = hours([0,4]) % The interval in which the fit statistics should be evaluated
    end

    % Frontend
    properties (Dependent)
        % Stack independent
        
        % Stack depth 1 (Data)
        FitVariables DataKit.Metadata.variable
        FitDeviceDomains GearKit.deviceDomain
        FitOriginTime datetime % The absolute time origin
        Time double % Time
        FluxParameter double % Flux parameters

        % Stack depth 2 (Exclusion evaluation)
        Exclude logical % Exclusions
        ExcludeFluxParameter logical

        % Stack depth 3 (Fits)
        Fits struct

        % Stack depth 4 (QC)

        % Stack depth 5 (Fluxes)
        Fluxes double
        FluxStatistics double
        Rates table
    end

    % Backend
    properties (Access = 'private')
        % Stack independent
        
        % Stack depth 1 (Data)
        FitVariables_ DataKit.Metadata.variable
        FitDeviceDomains_ GearKit.deviceDomain
        FitOriginTime_ datetime
        Time_ datetime
        FluxParameter_ double

        % Stack depth 2 (Exclusion evaluation)
        Exclude_ logical % Exclusions
        ExcludeFluxParameter_ logical

        % Stack depth 3 (Fits)
        Fits_ struct

        % Stack depth 4 (QC)

        % Stack depth 5 (Fluxes)
        Fluxes_ double
        FluxStatistics_ double
        Rates_ table
    end

  	properties (Hidden, Dependent)
        UpdateStack double
    end
    properties (Access = 'private')
        UpdateStack_ (5,1) double = 2.*ones(5,1) % Initialize as update required
    end
    properties
        FluxVolume double
        FluxCrossSection double

        FlagDataset DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.bigoFluxAnalysisDatasetFlag')
        FlagData DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.bigoFluxAnalysisDataFlag')
    end
    properties %(Hidden)
        PoolIndex double
        VariableIndex double
        TimeUnitFunction function_handle = @hours % Note: This must correspond to the TimeUnit property, as TimeUnit has the property attribute 'AbortSet' set.
        TimeVariable DataKit.Metadata.variable = DataKit.Metadata.variable.Time
    end
    properties (Dependent)
        NFits double
        NDeviceDomains double
        FitMinimumSamples
        NRates double
        RateIndex double
    end

    methods
        function obj = bigoFluxAnalysis(varargin)
        % bigoFluxAnalysis  Short description of the function/method
        %   BIGOFLUXANALYSIS long description goes here. It can hold multiple lines as it can
        %   go into lots of detail.
        %
        %   Syntax
        %     obj = BIGOFLUXANALYSIS()
        %     obj = BIGOFLUXANALYSIS(bigoDeployment)
        %     obj = BIGOFLUXANALYSIS(__,Name,Value)
        %
        %   Description
        %     obj = BIGOFLUXANALYSIS() Creates an empty bigoFluxAnalysis
        %       instance based on an empty bigoDeployment instance.
        %
        %     obj = BIGOFLUXANALYSIS(bigoDeployment) Creates a bigoFluxAnalysis
        %       instance based on the bigoDeployment instance.
        %
        %     obj = BIGOFLUXANALYSIS(__,Name,Value) Additionally define Name-Value
        %       pairs.
        %
        %   Example(s)
        %     obj = BIGOFLUXANALYSIS(bigoDeployment)
        %     obj = BIGOFLUXANALYSIS(bigoDeployment,'FitInterval',hours([0,7]))
        %     obj = BIGOFLUXANALYSIS(bigoDeployment,'TimeUnit','d')
        %
        %
        %   Input Arguments
        %     bigoDeployment - parent BIGO deployment
        %       GearKit.bigoDeployment
        %         BigoDeployment instance that the flux analysis is based on.
        %
        %
        %   Output Arguments
        %     obj - Constructed bigoFluxAnalysis instance
        %       AnalysisKit.bigoFluxAnalysis
        %         Handle to the constructed AnalysisKit.bigoFluxAnalysis instance.
        %
        %
        %   Name-Value Pair Arguments
        %     DeviceDomains - Device domains included in the flux analysis
        %       [Chamber1, Chamber2] (default) | GearKit.deviceDomain
        %         The device domain(s) of the parent bigoDeployment instance that
        %         are included in the flux analyis.
        %
        %     FitType - Type of fit
        %       'linear' (default)
        %         The fit type or method that is used to fit the incubation data.
        %
        %     FitInterval - Fit interval
        %       [0 hr, <deploymentDuration>] | 1x2 duration vector
        %         Only data points within the relative time interval FitInterval
        %         are included in the fitting. FitInterval(2) has to be greater
        %         than FitInterval(1).
        %
        %     FitEvaluationInterval - Fit statistics evaluation interval
        %       [0 hr, 4 hr] | 1x2 duration vector
        %         Only data points within the relative time interval FitInterval
        %         are included in the fitting. FitEvaluationInterval(2) has to
        %         be greater than FitEvaluationInterval(1).
        %
        %     TimeUnit - Relative time unit
        %       'h' (default') | 'ms' | 's' or 'sec' | 'm' or 'min' | 'd' | 'y'
        %         The duration unit used to normalize the fluxes to. The unit of
        %         the calculated fluxes corresponds to this: µmol/(m2 * d) or
        %         µmol/(m2 * h), etc..
        %
        %
        %   See also GEARKIT.BIGODEPLOYMENT, ANALYSISKIT.ANALYSIS
        %
        %   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
        %

            import DebuggerKit.Debugger.printDebugMessage
            import internal.stats.parseArgs

            if nargin == 0
                bigoDeployment = GearKit.bigoDeployment();
            elseif nargin >= 1
                bigoDeployment = varargin{1};
                varargin(1) = [];
            end

            % Input checks
            if ~isa(bigoDeployment,'GearKit.bigoDeployment')
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:bigoFluxAnalysis:invalidType',...
                    'Error','The first input has to be a GearKit.bigoDeployment instance.')
            end
            if ~isscalar(bigoDeployment)
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:bigoFluxAnalysis:nonScalarContext',...
                    'Error','The analysis can only be run on a single bigoDeployment instance.')
            end

            % Parse Name-Value pairs
            optionName          = {'DeviceDomains','FitType','FitInterval','FitEvaluationInterval','TimeUnit'}; % valid options (Name)
            optionDefaultValue  = {GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'}),'linear',[hours(0),bigoDeployment.timeRecovery - bigoDeployment.timeDeployment],hours([0,4]),'h'}; % default value (Value)
            [deviceDomains,...
             fitType,...
             fitInterval,...
             fitEvaluationInterval,...
             timeUnit] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments


            % Call superclass constructor
            obj = obj@AnalysisKit.analysis();

            % Add property listeners
            addlistener(obj,'TimeUnit','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            obj.TimeUnit                = timeUnit;

            % Populate properties
            % Update stack depth 1
            addlistener(obj,'Parent','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'DeviceDomains','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            validateattributes(bigoDeployment,{'GearKit.bigoDeployment'},{});
            obj.Parent                	= bigoDeployment;
            obj.DeviceDomains           = deviceDomains;

            % Update stack depth 2
            addlistener(obj,'FitType','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'FitInterval','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            obj.FitType                 = fitType;
            obj.FitInterval          	= fitInterval;

            % Update stack depth 3
            addlistener(obj,'FitEvaluationInterval','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            obj.FitEvaluationInterval  	= fitEvaluationInterval;
        end
    end

    % Methods in other files
    methods
        varargout   = plot(obj,varargin)
        checkUpdateStack(obj,stackDepth)
    end
    methods (Access = private)
        varargout = plotFits(obj,variable,showConfidenceInterval,axesProperties)
        varargout = plotFlux(obj,variable,groupingParameter,axesProperties)
        varargout = plotFluxViolin(obj,variable,groupingParameter,axesProperties)
    end

  	% Get methods
	methods
        function nFits = get.NFits(obj)
            nFits = numel(obj.FitVariables);
        end
        function nDeviceDomains = get.NDeviceDomains(obj)
            nDeviceDomains = numel(obj.DeviceDomains);
        end
        function fitMinimumSamples = get.FitMinimumSamples(obj)
            switch obj.FitType
                case 'linear'
                    fitMinimumSamples = 2;
                case 'poly2'
                    fitMinimumSamples = 3;
                case 'poly3'
                    fitMinimumSamples = 4;
                otherwise
                    error('''FitMinimumSamples'' is not defined for FitType ''%s'' yet.',obj.FitType)
            end
        end
        function nRates = get.NRates(obj)
            nRates = sum(~obj.ExcludeFluxParameter);
        end
        function rateIndex = get.RateIndex(obj)
            rateIndex = find(~obj.ExcludeFluxParameter);
        end
    end

    % Set methods
    methods
    end

    % Frontend/Backend interface: Get methods
    methods
        % Stack independent
        function updateStack = get.UpdateStack(obj)
            updateStack = obj.UpdateStack_;
        end

        % Stack depth 1
        function fitVariables = get.FitVariables(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            fitVariables = obj.FitVariables_;
        end
        function fitDeviceDomains = get.FitDeviceDomains(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            fitDeviceDomains = obj.FitDeviceDomains_;
        end
        function fitOriginTime = get.FitOriginTime(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            fitOriginTime = obj.FitOriginTime_;
        end
        function time = get.Time(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            time = obj.TimeUnitFunction(obj.Time_ - repmat(reshape(obj.FitOriginTime,1,[]),size(obj.Time_,1),1)); % Return time depending on
        end
        function fluxParameter = get.FluxParameter(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            fluxParameter = obj.FluxParameter_;
        end

        % Stack depth 2
        function exclude = get.Exclude(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            exclude = obj.Exclude_;
        end
        function excludeFluxParameter = get.ExcludeFluxParameter(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            excludeFluxParameter = obj.ExcludeFluxParameter_;
        end

        % Stack depth 3
        function fits = get.Fits(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            fits = obj.Fits_;
        end

        % Stack depth 4

        % Stack depth 5
        function fluxes = get.Fluxes(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxes = obj.Fluxes_;
        end
        function fluxStatistics = get.FluxStatistics(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxStatistics = obj.FluxStatistics_;
        end
        function rates = get.Rates(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            rates = obj.Rates_;
        end
    end

    % Frontend/Backend interface: Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags
        
        % Stack independent
        function obj = set.UpdateStack(obj,value)
            if ~isequal(obj.UpdateStack,value)
                % If the UpdateStack is set (modified), set all stackDepths below the first change to 'UpdateRequired'
                updateStackDepth           	= find(diff(cat(2,obj.UpdateStack_,value),1,2) == 2,1); % Status changes from Updated to UpdateRequired
                value(updateStackDepth:end) = 2; % Set all stati downstream to UpdateRequired
                obj.UpdateStack_            = value;
            end
        end
        
        % Stack depth 1
        function obj = set.FitVariables(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.FitVariables_           = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.FitDeviceDomains(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.FitDeviceDomains_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.FitOriginTime(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.FitOriginTime_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.Time(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Time_                   = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.FluxParameter(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.FluxParameter_        	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end

        % Stack depth 2
        function obj = set.Exclude(obj,value)
            stackDepth                  = 2;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Exclude_                = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.ExcludeFluxParameter(obj,value)
            stackDepth                  = 2;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.ExcludeFluxParameter_   = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end

        % Stack depth 3
        function obj = set.Fits_(obj,value)
            stackDepth                  = 3;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Fits_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end

        % Stack depth 4
        
        % Stack depth 5
        function obj = set.Fluxes_(obj,value)
            stackDepth                  = 5;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Fluxes_                 = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.FluxStatistics_(obj,value)
            stackDepth                  = 5;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.FluxStatistics_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.Rates_(obj,value)
            stackDepth                  = 5;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Rates_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
    end

    % Methods called from checkUpdateStack
    methods (Access = private)
        % Stack depth 1
        setFitVariables(obj)
        setRawData(obj)

        % Stack depth 2
        setExclusions(obj)

        % Stack depth 3
        calculateFits(obj)

        % Stack depth 4

        % Stack depth 5
        calculateFluxes(obj)
        createRateTable(obj)
    end

    % Event handler methods
    methods (Access = private)
        setRelativeTimeFunction(obj)
    end
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'Parent'
                    % The parent bigoDeployment object has been set. The raw data needs to be
                    % extracted again.
                    stackDepth  = 1;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
                case 'DeviceDomains'
                    % The device domains have been set. The raw data needs to be extracted
                    % again.
                    stackDepth  = 1;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)

                case 'FitInterval'
                    % A fitting parameter has been set. The exclusions need to be set again.
                    stackDepth  = 2;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)

                case 'FitType'
                    % A fitting parameter has been set. The fits need to be calculated again.
                    stackDepth  = 3;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
                case 'TimeUnit'
                    % The fit & flux are normalized to the time unit. The fits need to be
                    % recalculated.
                    stackDepth  = 3;
                    setRelativeTimeFunction(evnt.AffectedObject)
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)

                case 'FitEvaluationInterval'
                    % A fitting evaluation parameter has been set. The fluxes need to be
                    % recalculated.
                    stackDepth  = 5;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
            end
        end
    end
end
