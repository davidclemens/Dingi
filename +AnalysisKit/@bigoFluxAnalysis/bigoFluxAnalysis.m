classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS
    
    
    properties (SetObservable)
        Name char = 'BigoFlux' % Analysis name
        Type char = 'Flux' % Analysis type
        Parent = GearKit.bigoDeployment % Parent
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed
        
        Bigo GearKit.bigoDeployment
        
        FitType char = 'linear' % Fit method
        FitInterval duration = hours([0,5]) % The interval that should be fitted to
        FitEvaluationInterval duration = hours([0,4]) % The interval in which the fit statistics should be evaluated
        TimeUnit char = 'h'
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
            
            % Parse Name-Value pairs
            optionName          = {'deviceDomains','FitType','FitEvaluationInterval','TimeUnit','Parent'}; % valid options (Name)
            optionDefaultValue  = {GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'}),'linear',hours([0,4]),'h',bigoDeployment}; % default value (Value)
            [deviceDomains,...
             fitType,...
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
            
            % Populate properties
            validateattributes(parent,{'GearKit.bigoDeployment'},{});
            obj.Parent                	= parent;
            obj.Bigo                    = bigoDeployment;
            obj.FitType                 = fitType;
            obj.FitEvaluationInterval  	= fitEvaluationInterval;
            obj.TimeUnit                = timeUnit;
            obj.DeviceDomains           = deviceDomains;
            
            % Calculate
            obj.calculate;
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
    
    % Event handler methods
    methods (Access = private)
        setFitVariables(obj)
        setRelativeTimeFunction(obj)
        setRawData(obj)
    end
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'DeviceDomains'
                    setFitVariables(evnt.AffectedObject)
                case 'TimeUnit'
                    setRelativeTimeFunction(evnt.AffectedObject)
            end
        end
    end
end