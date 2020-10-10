classdef bigoFluxAnalysis < AnalysisKit.analysis
% BIGOFLUXANALYSIS


% TODO:
%   ( ) implement dealing with the data quality flags.
%   ( ) implement the use of the syringe/cap data
%   ( ) implement a mechanism to mark outliers
%
% IDEAS:
%   ( ) maybe derive from the handle class to support event listeners on
%       properties.
    
    
    properties
        name = 'bigoFlux' % Analysis name.
        type = 'flux' % Analysis type.
        
        fitType %
        fitInterval % (h)
        
        timeRaw
        fluxParameterRaw
        
        timeUnit
        fluxParameterUnit
        
        flux
    end
    properties %(Hidden)
        initialized = false
        excluded
        fitObjects
        fitGOF
        fitOutput
        
        indSource
        indParameter
        nFits
    end
    properties (Hidden, Constant)
        validFitTypes = {'linear','sigmoidal'};
    end
    methods
        function obj = bigoFluxAnalysis(time,fluxParameter,varargin)
                        
            % parse Name-Value pairs
            optionName          = {'FitType','FitInterval','TimeUnit','FluxParameterUnit'}; % valid options (Name)
            optionDefaultValue  = {'linear',[0,8],'h',repmat({' '},1,size(fluxParameter,2))}; % default value (Value)
            [FitType,...
             FitInterval,...
             TimeUnit,...
             FluxParameterUnit,...
                ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();
            
            % populate properties
            obj.timeRaw             = time;
            obj.fluxParameterRaw    = fluxParameter;
            
            obj.fitType             = FitType;
            obj.fitInterval         = FitInterval;
            obj.timeUnit            = TimeUnit;
            obj.fluxParameterUnit   = FluxParameterUnit;
            
            % initialize exclude mask to exclude NaNs
            obj.excluded            = cellfun(@(fp) isnan(fp),obj.fluxParameterRaw,'un',0);
            
            % intialize others
            [obj.indSource,obj.indParameter]    = find(~cellfun(@isempty,obj.fluxParameterRaw));
            obj.nFits                          	= numel(obj.indSource);
            
            % initialize flux
            obj.flux                = NaN(obj.nFits,3);
            
            % set initialized flag
            obj.initialized         = true;
            
            % calculate
            obj = obj.calculate();
        end
        
        % methods in other files
        obj         = calculate(obj,varargin)
        obj         = fit(obj,varargin)
        obj         = calculateFlux(obj)
        varargout   = plot(obj,varargin)
        func        = fitLinear(x,y,varargin)
        
        % get methods
        
        % set methods
        function obj = set.fitType(obj,value)
            obj.fitType     = validatestring(value,obj.validFitTypes);
            if obj.initialized
                obj	= obj.calculate();
            end            
        end
    end
end