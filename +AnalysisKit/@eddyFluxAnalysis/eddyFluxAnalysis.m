classdef eddyFluxAnalysis < AnalysisKit.analysis
% EDDYFLUXANALYSIS
%


% TODO:
%   ( ) implement new velocityRaw, velocity, velocityRotated, etc. ...
%   (x) reshape timeseries so that dim2 represents the windows to make per-
%       window calculations easier.
%   ( ) implement despiking.
%   ( ) implement time-shift correction between velocity and fluxParameters
%   ( ) implement custom moving window size for detrending method 'moving
%       mean'.
%   (x) implement subsampling of the original dataset
%   ( ) implement setting start and end time of the analysis
%   ( ) implement get & set property access methods
%
% IDEAS:
%   ( ) maybe derive from the handle class to support event listeners on
%       properties.
    
    
    properties
        name = 'eddyFlux' % Analysis name.
        type = 'flux' % Analysis type.
        
        timeRaw % Raw Time (datenum).
        velocityRaw % Raw velocity (m/s).
        fluxParameterRaw % Raw flux parameter.
        
        window duration % Window (duration)
        downsamples % Subsampling is applied first
        coordinateSystemRotationMethod char
        detrendingMethod char
        
        timeDownsampled
        velocityDownsampled
        fluxParameterDownsampled
        
        w_ % Rotated and trend corrected vertical velocity (m/s)
        fluxParameter_ % Trend corrected flux parameter
    end
    properties %(Hidden)
        coordinateSystemUnitVectorI
        coordinateSystemUnitVectorJ
        coordinateSystemUnitVectorK
        detrendingFunction
        initialized logical = false
    end
    properties (Dependent)
        frequency % Frequency (Hz)
        sampleWindowedN double % Number of samples in windows
        
       	time % Time (datenum). Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window]. The Size is windowLength x windowN.
        velocity % Velocity (m/s). Rotated according to the CoordinateSystemRotationMethod. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[vx,vy,vz]]. The Size is windowLength x windowN x 3.
        fluxParameter % flux parameter. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[fluxParameters]]. The Size is windowLength x windowN x fluxParameterN.
    end
    properties (Dependent) %Hidden
        sampleN % Number of raw samples
        fluxParameterN % Number of flux parameters
        windowLength % Window length (samples)
        windowN % Number of full windows in timeseries
        windowPaddingLength % Padding length (samples) of the last incomplete window.
        coordinateSystemUnitVectors
    end
    properties (Hidden, Constant)
        validCoordinateSystemRotationMethods = {'none','planar fit'};
        validDetrendingMethods = {'none','mean removal','linear','moving mean'};
    end
    methods
        function obj = eddyFluxAnalysis(time,velocity,fluxParameter,varargin)
                        
            % parse Name-Value pairs
            optionName          = {'Window','Downsamples','CoordinateSystemRotationMethod','DetrendingMethod'}; % valid options (Name)
            optionDefaultValue  = {duration(0,10,0),4,'planar fit','moving mean'}; % default value (Value)
            [Window,...
             Downsamples,...
             CoordinateSystemRotationMethod,...
             DetrendingMethod,...
             ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();
            
            % populate properties
            obj.timeRaw                         = time;
            obj.velocityRaw                     = velocity;
            obj.fluxParameterRaw                = fluxParameter;
            
            obj.window                          = Window;
            obj.downsamples                     = Downsamples;
            obj.coordinateSystemRotationMethod	= CoordinateSystemRotationMethod;
            obj.detrendingMethod                = DetrendingMethod;
            
            % set initialized flag
            obj.initialized                     = true;
            
            % calculate
            obj     = obj.calculate(...
                        'Downsample',                   true,...
                        'RotateCoordinateSystem',       true,...
                        'DetrendFluxParameter',         true,...
                        'DetrendVerticalVelocity',      true);
        end
        
        % methods in other files
        obj         = calculate(obj,varargin)
        obj         = planarFitCoordinateSystem(obj)
        obj         = detrend(obj,varargin)
        [i,j,k]     = csUnitVectors(obj)
        func        = dGetDetrendingFunction(obj,detrendingOptions)
        varargout   = plot(obj,varargin)
        
        % get methods
        function time = get.time(obj)
            time = reshape(cat(1,obj.timeDownsampled,NaN(obj.windowPaddingLength,1)),obj.windowLength,obj.windowN + 1);
        end
        function velocity = get.velocity(obj)
            tmpVelocity	= permute(reshape(shiftdim(cat(1,obj.velocityDownsampled,NaN(obj.windowPaddingLength,3)),-1),obj.windowLength,obj.windowN + 1,[]),[1,3,2]);
        	velocity 	= NaN(obj.windowLength,obj.windowN + 1,3);
            for win = 1:obj.windowN + 1
                velocity(:,win,:) = tmpVelocity(:,:,win)*obj.coordinateSystemUnitVectors(:,:,win);
            end
        end
        function fluxParameter = get.fluxParameter(obj)
            fluxParameter = reshape(shiftdim(cat(1,obj.fluxParameterDownsampled,NaN(obj.windowPaddingLength,obj.fluxParameterN)),-1),obj.windowLength,obj.windowN + 1,[]);
        end
        
        
        function frequency = get.frequency(obj)
            frequency = round(1/(nanmean(diff(obj.timeRaw))*24*60^2),6,'Significant')/obj.downsamples;
        end
        function coordinateSystemUnitVectors = get.coordinateSystemUnitVectors(obj)
            coordinateSystemUnitVectors = cat(3,obj.coordinateSystemUnitVectorI,obj.coordinateSystemUnitVectorJ,obj.coordinateSystemUnitVectorK);
            coordinateSystemUnitVectors = permute(coordinateSystemUnitVectors,[3,2,1]);
        end
        function sampleN = get.sampleN(obj)
            sampleN = size(obj.timeDownsampled,1);
        end
        function fluxParameterN = get.fluxParameterN(obj)
            fluxParameterN = size(obj.fluxParameterDownsampled,2);
        end
        function windowLength = get.windowLength(obj)
            windowLength = floor(obj.frequency*seconds(obj.window));
        end
        function windowN = get.windowN(obj)
            windowN = floor(size(obj.velocityDownsampled,1)/obj.windowLength);
        end
        function windowPaddingLength = get.windowPaddingLength(obj)
            windowPaddingLength = obj.windowLength - (obj.sampleN - obj.sampleWindowedN);
        end
        function sampleWindowedN = get.sampleWindowedN(obj)
            sampleWindowedN = obj.windowLength*obj.windowN;
        end
        
        % set methods
        function obj = set.sampleN(obj,value)
            if ~obj.initialized
                obj.sampleN = value;
            else
                error('GearKit:eddyFluxAnalysis:sampleNNotSetable',...
                      'SampleN is only set once during object construction.')
            end
        end
        function obj = set.downsamples(obj,value)
            validateattributes(value,{'numeric'},{'scalar','integer','nonzero','positive'});
            obj.downsamples = value;
            if obj.initialized
                obj	= obj.calculate(...
                        'Downsample',                   true,...
                        'RotateCoordinateSystem',       false,...
                        'DetrendFluxParameter',         true,...
                        'DetrendVerticalVelocity',      true);
            end            
        end
        function obj = set.coordinateSystemRotationMethod(obj,value)
            obj.coordinateSystemRotationMethod = validatestring(value,obj.validCoordinateSystemRotationMethods);
            if obj.initialized
                obj	= obj.calculate(...
                        'Downsample',                   false,...
                        'RotateCoordinateSystem',       true,...
                        'DetrendFluxParameter',         false,...
                        'DetrendVerticalVelocity',      true);
            end
        end
        function obj = set.detrendingMethod(obj,value)
            obj.detrendingMethod = validatestring(value,obj.validDetrendingMethods);
            if obj.initialized
                obj	= obj.calculate(...
                        'Downsample',                   false,...
                        'RotateCoordinateSystem',       false,...
                        'DetrendFluxParameter',         true,...
                        'DetrendVerticalVelocity',      true);
            end
        end
        function obj = set.window(obj,value)
            obj.window = value;
            if obj.initialized
                obj	= obj.calculate(...
                        'Downsample',                   true,...
                        'RotateCoordinateSystem',       true,...
                        'DetrendFluxParameter',         true,...
                        'DetrendVerticalVelocity',      true);
            end
        end
    end
    methods (Static)
        % methods in other files
        y           = downsample(x,N)
        y           = detrendMeanRemoval(x)
        y           = detrendLinear(x)
        y           = detrendMovingMean(x,window)
        
        [k,b0]      = csPlanarFitUnitVectorK(U1)
        [i,j]       = csPlanarFitUnitVectorIJ(U1,k)
%         [uc,vc,wc] = csPlanarFitRotateScalarFlux(u1c,v1c,w1c,i,j,k)
%         [uu,vv,ww,uw,vw]=csPlanarFitRotateVelocityStat(u,i,j,k)
    end
end