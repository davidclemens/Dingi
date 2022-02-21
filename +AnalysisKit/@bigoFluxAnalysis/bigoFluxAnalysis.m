classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS
    
    
    properties (SetObservable)
        Name char = 'BigoFlux' % Analysis name
        Type char = 'Flux' % Analysis type
        Parent = GearKit.bigoDeployment % Parent
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed
        
        FitType char = 'linear' % Fit method
        FitInterval duration = hours([0,5]) % The interval that should be fitted to
        FitEvaluationInterval duration = hours([0,4]) % The interval in which the fit statistics should be evaluated
        TimeUnit char = 'h'
    end
    
    % Frontend
    properties (Dependent)
        % Stack depth 1 (Data)
        Time double % Time
        FluxParameter double % Flux parameters
        Exclusions logical % Exclusions
        
        % Stack depth 2 (Quality control)
        FluxParameterQC double
    end
    
    % Backend
    properties (Access = 'private')
        % Stack depth 1 (Data)
        Time_ datetime
        FluxParameter_ double
        Exclusions_ logical % Exclusions
        
        % Stack depth 2 (Quality control)
        FluxParameterQC_ double
    end
    
  	properties (Dependent) %Access = 'private', 
        UpdateStack
    end
    properties (Access = 'private')
        UpdateStack_ = 2.*ones(2,1) % Initialize as update required
    end
    properties
        NFits double
        
        FluxStatistics
        Flux
        FluxConfInt
        
        FluxVolume double
        FluxCrossSection double
    end
    properties %(Hidden)
        PoolIndex double
        VariableIndex double
        TimeUnitFunction function_handle = @(x) x
        TimeVariable DataKit.Metadata.variable = DataKit.Metadata.variable.Time
        
        FitOriginTime datetime % The absolute time origin
        FitStartTime duration % The relative time offset of the fit start from the FitOriginTime
        FitEndTime duration % The relative time offset of the fit end from the FitOriginTime
        
        FitDeviceDomains GearKit.deviceDomain
        FitObjects cell
        FitGOF
        FitOutput
        FitVariables DataKit.Metadata.variable
    end
    properties (Dependent)
        NDeviceDomains
    end
    properties (Hidden, Constant)
        ValidFitTypes = {'linear','sigmoidal'};
    end
    
    methods
        function obj = bigoFluxAnalysis(bigoDeployment,varargin)
                        
            import internal.stats.parseArgs
            import GearKit.bigoDeployment
            
            % Check for at least 1 input argument
            narginchk(1,Inf)
            
            % Parse Name-Value pairs
            optionName          = {'DeviceDomains','FitType','FitInterval','FitEvaluationInterval','TimeUnit','Parent'}; % valid options (Name)
            optionDefaultValue  = {GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'}),'linear',hours(NaN(1,2)),hours([0,4]),'h',bigoDeployment}; % default value (Value)
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
            addlistener(obj,'DeviceDomains','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'TimeUnit','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'Parent','PostSet',@AnalysisKit.bigoFluxAnalysis.handlePropertyChangeEvents);
            
            % Populate properties
            % Update stack depth 1
            validateattributes(parent,{'GearKit.bigoDeployment'},{});
            obj.Parent                	= parent;
            obj.DeviceDomains           = deviceDomains;
            
            % Update stack depth 2
            obj.FitType                 = fitType;
            obj.FitInterval          	= fitInterval;
            obj.FitEvaluationInterval  	= fitEvaluationInterval;
            obj.TimeUnit                = timeUnit;
            
            % Calculate
%             obj.calculate;
        end
    end
    
    % Methods in other files
    methods
        setFitExclusions(obj)
        calculate(obj,varargin)
        fit(obj,varargin)
        calculateFlux(obj)
        
        varargout   = plot(obj,varargin)
        func        = fitLinear(x,y,varargin)
        tbl         = getFlux(obj,variables)
    end
    methods (Access = private)
        varargout = plotFits(obj,variable,axesProperties)
        varargout = plotFlux(obj,variable,axesProperties)
    end
        
  	% Get methods
	methods
        function NDeviceDomains = get.NDeviceDomains(obj)
            NDeviceDomains = numel(obj.DeviceDomains);
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
        function exclusions = get.Exclusions(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            exclusions = obj.Exclusions_;
        end
        
        
        function fluxParameterQC = get.FluxParameterQC(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            fluxParameterQC = obj.FluxParameterQC_;
        end
    end
    
    % Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags.
        function obj = set.Time(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.Time_                   = value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        function obj = set.FluxParameter(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.FluxParameter_        	= value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        function obj = set.Exclusions(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.Exclusions_             = value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        
        function obj = set.FluxParameterQC_(obj,value)
            stackDepth                  = 2;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.FluxParameterQC_      	= value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
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
    
    
    
    % Event handler methods
    methods (Access = private)
        setFitVariables(obj)
        setRelativeTimeFunction(obj)
        setRawData(obj)
    end
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'Parent'
                    % The parent bigoDeployment object has been set. The raw data needs to be
                    % extracted again.
                    stackDepth  = 1;
                    evnt.AffectedObject.UpdateStack(stackDepth) = 2; % Set to 'UpdateRequired'
                case 'DeviceDomains'
                    % The device domains have been set. The raw data needs to be extracted
                    % again.
                    stackDepth  = 1;
                    evnt.AffectedObject.UpdateStack(stackDepth) = 2; % Set to 'UpdateRequired'
                case 'TimeUnit'
                    setRelativeTimeFunction(evnt.AffectedObject)
            end
        end
    end
end