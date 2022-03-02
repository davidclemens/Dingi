classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS
    
    
    properties (SetObservable, AbortSet)
        Name char = 'BigoFlux' % Analysis name
        Type char = 'Flux' % Analysis type
        Parent = GearKit.bigoDeployment % Parent
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed
        
        TimeUnit (1,:) char = 'h'
        
        FitType (1,:) char {mustBeMember(FitType,{'linear'})} = 'linear' % Fit method
        FitInterval (1,2) duration = hours([0,5]) % The interval that should be fitted to
        FitEvaluationInterval (1,2) duration = hours([0,4]) % The interval in which the fit statistics should be evaluated
    end
    
    % Frontend
    properties (Dependent)
        % Stack depth 1 (Data)
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
    end
    
    % Backend
    properties (Access = 'private')
        % Stack depth 1 (Data)
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
    end
    
  	properties (Dependent) %Access = 'private', 
        UpdateStack
    end
    properties (Access = 'private')
        UpdateStack_ (5,1) double = 2.*ones(5,1) % Initialize as update required
    end
    properties
        NFits double
        
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
        
        FitOriginTime datetime % The absolute time origin
        FitStartTime duration % The relative time offset of the fit start from the FitOriginTime
        FitEndTime duration % The relative time offset of the fit end from the FitOriginTime
        
        FitDeviceDomains GearKit.deviceDomain
        FitVariables DataKit.Metadata.variable
    end
    properties (Dependent)
        NDeviceDomains
        FitMinimumSamples
        NRates
        RateIndex
    end
    
    methods
        function obj = bigoFluxAnalysis(bigoDeployment,varargin)
                        
            import internal.stats.parseArgs
            import GearKit.bigoDeployment
            
            % Check for at least 1 input argument
            narginchk(1,Inf)
            
            % Parse Name-Value pairs
            optionName          = {'DeviceDomains','FitType','FitInterval','FitEvaluationInterval','TimeUnit','Parent'}; % valid options (Name)
            optionDefaultValue  = {GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'}),'linear',[hours(0),bigoDeployment.timeRecovery - bigoDeployment.timeDeployment],hours([0,4]),'h',bigoDeployment}; % default value (Value)
            [deviceDomains,...
             fitType,...
             fitInterval,...
             fitEvaluationInterval,...
             timeUnit,...
             parent] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            % Input checks
            if ~isscalar(bigoDeployment)
                error('Dingi:AnalysisKit:bigoFluxAnalysis:bigoFluxAnalysis:nonScalarContext',...
                    'The analysis can only be run on a single bigoDeployment instance.')
            end

            % Call superclass constructor
            obj = obj@AnalysisKit.analysis();
            
            % Add property listeners
            addlistener(obj,'TimeUnit','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            obj.TimeUnit                = timeUnit;
            
            % Populate properties
            % Update stack depth 1
            addlistener(obj,'Parent','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'DeviceDomains','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            validateattributes(parent,{'GearKit.bigoDeployment'},{});
            obj.Parent                	= parent;
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
        func        = fitLinear(x,y,varargin)
        tbl         = getFlux(obj,variables)
        
        checkUpdateStack(obj,stackDepth)
    end
    methods (Access = private)
        varargout = plotFits(obj,variable,axesProperties)
        varargout = plotFlux(obj,variable,axesProperties)
    end
        
  	% Get methods
	methods
        function nDeviceDomains = get.NDeviceDomains(obj)
            nDeviceDomains = numel(obj.DeviceDomains);
        end
        function fitMinimumSamples = get.FitMinimumSamples(obj)
            switch obj.FitType
                case 'linear'
                    fitMinimumSamples = 2;
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
    
    % Get methods
    methods
        % Frontend/Backend interface
        function updateStack = get.UpdateStack(obj)
            updateStack = obj.UpdateStack_;
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
        
        function fits = get.Fits(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            fits = obj.Fits_;
        end
        
        function fluxes = get.Fluxes(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxes = obj.Fluxes_;
        end
        function fluxeStatistics = get.FluxStatistics(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxeStatistics = obj.FluxeStatistics_;
        end
    end
    
    % Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags.
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
        
        function obj = set.Fits_(obj,value)
            stackDepth                  = 3;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Fits_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        
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
        
        function obj = set.UpdateStack(obj,value)
            if ~isequal(obj.UpdateStack,value)
                % If the UpdateStack is set (modified), set all stackDepths below the first change to 'UpdateRequired'
                updateStackDepth           	= find(diff(cat(2,obj.UpdateStack_,value),1,2) == 2,1); % Status changes from Updated to UpdateRequired
                value(updateStackDepth:end) = 2; % Set all stati downstream to UpdateRequired
                obj.UpdateStack_            = value;
            end
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