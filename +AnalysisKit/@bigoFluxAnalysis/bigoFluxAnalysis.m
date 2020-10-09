classdef bigoFluxAnalysis < AnalysisKit.analysis
% EDDYFLUXANALYSIS
%


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
        
    end
    properties %(Hidden)
        initialized = false
        excluded
    end
    properties (Hidden, Constant)
        validFitTypes = {'linear','sigmoidal'};
    end
    methods
        function obj = bigoFluxAnalysis(time,fluxParameter,varargin)
                        
            % parse Name-Value pairs
            optionName          = {'FitType','FitInterval'}; % valid options (Name)
            optionDefaultValue  = {'linear',[0,8]}; % default value (Value)
            [FitType,...
             FitInterval,...
                ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();
            
            % populate properties
            obj.timeRaw             = time;
            obj.fluxParameterRaw    = fluxParameter;
            
            obj.fitType             = FitType;
            obj.fitInterval         = FitInterval;
            
            % set initialized flag
            obj.initialized         = true;
            
            % calculate
            obj = obj.calculate();
        end
        
        % methods in other files
        obj         = calculate(obj,varargin)
        obj         = fit(obj,varargin)
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