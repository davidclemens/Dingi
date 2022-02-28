classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS
    
    
    properties (SetObservable, AbortSet)
        Name char = 'BigoFlux' % Analysis name
        Type char = 'Flux' % Analysis type
        Parent = GearKit.bigoDeployment % Parent
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed
        
        FitType (1,:) char {mustBeMember(FitType,{'linear'})} = 'linear' % Fit method
        FitInterval (1,2) duration = hours([0,5]) % The interval that should be fitted to
        FitEvaluationInterval (1,2) duration = hours([0,4]) % The interval in which the fit statistics should be evaluated
        TimeUnit (1,:) char = 'h'
    end
    
    % Frontend
    properties (Dependent)
        % Stack depth 1 (Data)
        Time double % Time
        FluxParameter double % Flux parameters
        Exclusions logical % Exclusions
        
        % Stack depth 2 (Fits)
        Fits
        
        % Stack depth 3 (Fluxes)
        Fluxes
    end
    
    % Backend
    properties (Access = 'private')
        % Stack depth 1 (Data)
        Time_ datetime
        FluxParameter_ double
        Exclusions_ logical % Exclusions
        
        % Stack depth 2 (Fits)
        Fits_
        
        % Stack depth 3 (Fluxes)
        Fluxes_
    end
    
  	properties (Dependent) %Access = 'private', 
        UpdateStack
    end
    properties (Access = 'private')
        UpdateStack_ (3,1) double = 2.*ones(3,1) % Initialize as update required
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
        TimeUnitFunction function_handle = @hours % Note: This must correspond to the TimeUnit property, as TimeUnit has the property attribute 'AbortSet' set.
        TimeVariable DataKit.Metadata.variable = DataKit.Metadata.variable.Time
        
        FitOriginTime datetime % The absolute time origin
        FitStartTime duration % The relative time offset of the fit start from the FitOriginTime
        FitEndTime duration % The relative time offset of the fit end from the FitOriginTime
        
        FitDeviceDomains GearKit.deviceDomain
%         FitObjects cell
%         FitGOF
%         FitOutput
        FitVariables DataKit.Metadata.variable
    end
    properties (Dependent)
        NDeviceDomains
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
        
        function fits = get.Fits(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            fits = obj.Fits_;
        end
        
        function fluxes = get.Fluxes(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            fluxes = obj.Fluxes_;
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
        
        function obj = set.Fits_(obj,value)
            stackDepth                  = 2;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.Fits_      	= value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        
        function obj = set.Fluxes_(obj,value)
            stackDepth                  = 3;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.Fluxes_      	= value;
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
    
    % Methods called from checkUpdateStack
    methods (Access = private)
        setFitVariables(obj)
        setRawData(obj)
        
        % Stack depth 2
        calculateFits(obj)
        
        % Stack depth 3
        calculateFluxes(obj)
    end
    
    % Event handler methods
    methods (Access = private)
        setRelativeTimeFunction(obj)
    end
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'TimeUnit'
                    setRelativeTimeFunction(evnt.AffectedObject)
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
                case 'FitType'
                    % A fitting parameter has been set. The fits need to be calculated again.
                    stackDepth  = 2;
                    evnt.AffectedObject.UpdateStack(stackDepth) = 2; % Set to 'UpdateRequired'
                case 'FitInterval'
                    % A fitting parameter has been set. The fits need to be calculated again.
                    stackDepth  = 2;
                    evnt.AffectedObject.UpdateStack(stackDepth) = 2; % Set to 'UpdateRequired'
                case 'FitEvaluationInterval'
                    % A fitting evaluation parameter has been set. The fluxes need to be
                    % recalculated.
                    stackDepth  = 3;
                    evnt.AffectedObject.UpdateStack(stackDepth) = 2; % Set to 'UpdateRequired'
            end
        end
    end
end