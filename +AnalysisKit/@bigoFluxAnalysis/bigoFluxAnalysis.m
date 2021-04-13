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
        
        meta
        timeUnit
        
        fluxStatistics
        flux
        fluxConfInt
        
        fluxVolume
        fluxCrossSection
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
    properties (Dependent)
        fluxParameterId
        fluxParameterUnit
    end
    properties (Hidden, Constant)
        validFitTypes = {'linear','sigmoidal'};
    end
    methods
        function obj = bigoFluxAnalysis(time,fluxParameterData,meta,varargin)
                        
            % parse Name-Value pairs
            optionName          = {'FitType','FitInterval','TimeUnit','FluxVolume','FluxCrossSection','Outlier'}; % valid options (Name)
            optionDefaultValue  = {'linear',[0,8],'h',ones(size(fluxParameterData,1),1),ones(size(fluxParameterData,1),1),cellfun(@(s) false(size(s)),fluxParameterData,'un',0)}; % default value (Value)
            [FitType,...
             FitInterval,...
             TimeUnit,...
             FluxVolume,...
             FluxCrossSection,...
             Outlier...
                ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();
            
            % populate properties
            obj.timeRaw             = time;
            obj.fluxParameterRaw    = fluxParameterData;
            
            obj.fitType             = FitType;
            obj.fitInterval         = FitInterval;
            
            obj.meta                = meta;
            
            obj.timeUnit            = TimeUnit;
            
            obj.fluxVolume          = FluxVolume;
            obj.fluxCrossSection    = FluxCrossSection;
            
            % initialize exclude mask to exclude NaNs
            obj.excluded  	= cellfun(@(fp,o) isnan(fp) | o,obj.fluxParameterRaw,Outlier,'un',0);
            
            % intialize others
            [obj.indSource,obj.indParameter]    = find(~cellfun(@isempty,obj.fluxParameterRaw));
            obj.nFits                          	= numel(obj.indSource);
            
            % initialize flux
            obj.flux       	= NaN(obj.nFits,3);
            
            % set initialized flag
            obj.initialized	= true;
            
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
        
        tbl         = getFlux(obj,parameters)
        
        % get methods
        function fluxParameterUnit = get.fluxParameterUnit(obj)
            [~,parameterInfo]   = DataKit.validateParameterId(obj.fluxParameterId);
            fluxParameterUnit   = cellstr(parameterInfo{:,'Unit'})';
        end
        function fluxParameterId = get.fluxParameterId(obj)
            fluxParameterId     = obj.meta(1).parameterId;
        end
        
        % set methods
        function obj = set.fitType(obj,value)
            obj.fitType     = validatestring(value,obj.validFitTypes);
            if obj.initialized
                obj	= obj.calculate();
            end            
        end
    end
end