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
%   (x) implement flags to track which data points were manipulated
%   ( ) implement NaNs
%
% IDEAS:
%   (x) maybe derive from the handle class to support event listeners on
%       properties.

    % Frontend
    properties
        Name char = 'eddyFlux' % Analysis name
        Type char = 'flux' % Analysis type
        Parent = GearKit.ecDeployment % Parent
    end
    
    properties
        SNR (:,3) double % Signal to noise ratio
        BeamCorrelation (:,3) double % Beam correlation
    end
    properties (Dependent)
        TimeRaw (:,1) double % Raw Time (datenum)
        VelocityRaw (:,3) double % Raw velocity (m/s)
        FluxParameterRaw double % Raw flux parameter data
        
        TimeDS (:,1) double % Downsampled time (datenum)
        VelocityDS (:,3) double % Downsampled velocity (m/s)
        FluxParameterDS double % Downsampled flux parameter data
        
        TimeQC (:,1) double % Quality controlled time (datenum)
        VelocityQC (:,3) double % Quality controlled velocity (m/s)
        FluxParameterQC double % Quality controlled flux parameter data
    end
    properties
        SNRDS (:,3) double % Downsampled signal to noise ratio
        BeamCorrelationDS (:,3) double % Downsampled beam correlation
        
        W_ (:,1) double % Rotated and trend corrected vertical velocity (m/s)
        FluxParameter_ double % Trend corrected flux parameter
        
        FlagDataset DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDatasetFlag',1,1)
        FlagTime DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
        FlagVelocity DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
        FlagFluxParameter DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
    end
    properties
        Window duration % Window or averaging interval (duration)
        DespikeMethod char = 'phase-space thresholding' % Despiking method
        Downsamples = 1 % Number of downlsamples.
        CoordinateSystemRotationMethod char = 'planar fit'
        DetrendingMethod char = 'moving mean' % Detrending method
        ReplaceMethod char = 'linear' % Method to use to replace rejected data points


        StartTime (1,1) datetime
        EndTime (1,1) datetime

        FluxParameterTimeShift (1,:) double % Time shift of the flux parameter (# of samples)

        
        ObstacleAngles (:,1) double % The anticlockwise angle(s) seen from above the lander starting with 0° on the ADV x-axis, where obstacles (legs, sensors, etc.) are located.
        ObstacleSectorWidth (1,1) double = 5 % Sector width in degrees
    end
    
    % Backend
    properties (Access = 'private')
        TimeRaw_ (:,1) double % Raw Time (datenum)
        VelocityRaw_ (:,3) double % Raw velocity (m/s)
        FluxParameterRaw_ double % Raw flux parameter data
        
        TimeDS_ (:,1) double % Downsampled time (datenum)
        VelocityDS_ (:,3) double % Downsampled velocity (m/s)
        FluxParameterDS_ double % Downsampled flux parameter data
        
        TimeQC_ (:,1) double % Quality controlled time (datenum)
        VelocityQC_ (:,3) double % Quality controlled velocity (m/s)
        FluxParameterQC_ double % Quality controlled flux parameter data        
    end
    properties (Access = 'private')
        % Update required flags (UpdateRequired, IsUpdating, IsUpdated)
        UpdateDownsamples char = 'UpdateRequired'
        UpdateQC char = 'UpdateRequired'
        UpdateFluxes char = 'UpdateRequired'
    end
    properties %(Hidden)
        CoordinateSystemUnitVectorI (:,3) double
        CoordinateSystemUnitVectorJ (:,3) double
        CoordinateSystemUnitVectorK (:,3) double
        DetrendingFunction
        Initialized logical = false
    end
    properties (Dependent)
        Frequency (1,1) double % Frequency (Hz)
        SampleWindowedN double % Number of samples in windows

       	Time % Time (datenum). Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window]. The Size is windowLength x windowN.
        Velocity % Velocity (m/s). Rotated according to the CoordinateSystemRotationMethod. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[vx,vy,vz]]. The Size is windowLength x windowN x 3.
        FluxParameter % flux parameter. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[fluxParameters]]. The Size is windowLength x windowN x fluxParameterN.
    end
    properties (Dependent) %Hidden
        SampleN % Number of raw samples
        FluxParameterN % Number of flux parameters
        WindowLength % Window length (samples)
        WindowN % Number of full windows in timeseries
        WindowPaddingLength % Padding length (samples) of the last incomplete window.
        CoordinateSystemUnitVectors
        WindowMask % Windows that fully lie within the [StartTime,EndTime] interval
    end
    properties (Hidden, Constant)
        ValidCoordinateSystemRotationMethods = {'none','planar fit'};
        ValidDetrendingMethods = {'none','mean removal','linear','moving mean'};
        ValidDespikingMethods = {'none','phase-space thresholding'};
    end
    methods
        function obj = eddyFluxAnalysis(time,velocity,fluxParameter,varargin)

            import internal.stats.parseArgs
            import GearKit.ecDeployment

            % parse Name-Value pairs
            optionName          = {'SNR','BeamCorrelation','Window','Downsamples','CoordinateSystemRotationMethod','DetrendingMethod','DespikeMethod','Start','End','ObstacleAngles','Parent'}; % valid options (Name)
            optionDefaultValue  = {[],[],duration(0,30,0),2,'planar fit','moving mean','phase-space thresholding',[],[],[],ecDeployment}; % default value (Value)
            [snr,...
             beamCorrelation,...
             window,...
             downsamples,...
             coordinateSystemRotationMethod,...
             detrendingMethod,...
             despikeMethod,...
             startTime,...
             endTime,...
             obstacleAngles,...
             parent...
             ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();

            % populate properties
            validateattributes(parent,{'GearKit.ecDeployment'},{});
            obj.Parent                          = parent;
            obj.Window                          = window;
            obj.Downsamples                     = downsamples;
            obj.CoordinateSystemRotationMethod	= validatestring(coordinateSystemRotationMethod,obj.ValidCoordinateSystemRotationMethods);
            obj.DetrendingMethod                = validatestring(detrendingMethod,obj.ValidDetrendingMethods);
            obj.DespikeMethod                   = validatestring(despikeMethod,obj.ValidDespikingMethods);
            obj.ObstacleAngles                  = obstacleAngles;

            if isempty(startTime)
                obj.StartTime   = datetime(time(1),'ConvertFrom','datenum');
            elseif ~isempty(startTime) && isdatetime(startTime)
                obj.StartTime   = startTime;
            else
                error('')
            end

            if isempty(endTime)
                obj.EndTime   = datetime(time(end),'ConvertFrom','datenum');
            elseif ~isempty(endTime) && isdatetime(endTime)
                obj.EndTime   = endTime;
            else
                error('')
            end

            % Populate data
            obj.SNR                             = snr;
            obj.BeamCorrelation                 = beamCorrelation;
            
            obj.TimeRaw                         = time;
            obj.VelocityRaw                     = velocity;
            obj.FluxParameterRaw                = fluxParameter;
            
            % set initialized flag
            obj.Initialized	= true;

            % calculate
%             obj.calculate(...
%                 'Downsample',                   true,...
%                 'RotateCoordinateSystem',       true,...
%                 'DetrendFluxParameter',         true,...
%                 'DetrendVerticalVelocity',      true,...
%                 'TimeShift',                    true,...
%                 'CalculateCospectrum',          true);
        end
    end

	% Methods in other files
    methods
        varargout = runDownsampling(obj)
        varargout = runQualityControl(obj)
        varargout = despike(obj)
        varargout = calculate(obj,varargin)
        varargout = planarFitCoordinateSystem(obj)
        varargout = detrend(obj,varargin)
        varargout = timeShift(obj)
        varargout = calculateCospectrum(obj)
        [i,j,k] = csUnitVectors(obj)
        func = dGetDetrendingFunction(obj,detrendingOptions)
        varargout = plot(obj,varargin)
        varargout = plotSpectra(obj,window)
        varargout = plotQualityControlStatistics(obj,fig)
        varargout = plotQualityControl(obj,fig,datasetName,varargin)
        varargout = plotTracerPath(obj,fig)
    end
    methods (Access = private)
        varargout = qualityControlRawData(obj)
        varargout = despikePST(obj,datasetName)
        varargout = replaceData(obj,flag)
        checkForMissingData(obj)
        checkForAbsoluteLimits(obj)
        checkForSpikes(obj)
        checkForCurrentObstructions(obj)
        checkForAmplitudeResolution(obj)
        checkForDropouts(obj)
        checkForSignalToNoiseRatio(obj)
        checkForBeamCorrelation(obj)
        
    end

    methods (Static)
        % methods in other files
        y = downsample(x,N)
        y = detrendMeanRemoval(x)
        y = detrendLinear(x)
        y = detrendMovingMean(x,window)

        [k,b0] = csPlanarFitUnitVectorK(U1)
        [i,j] = csPlanarFitUnitVectorIJ(U1,k)
%         [uc,vc,wc] = csPlanarFitRotateScalarFlux(u1c,v1c,w1c,i,j,k)
%         [uu,vv,ww,uw,vw]=csPlanarFitRotateVelocityStat(u,i,j,k)


        varargout = plotPhaseSpace(x,dx,d2x,uniCrit,theta)
    end

    % Get methods
    methods
        % Frontend/Backend interface
        function timeRaw = get.TimeRaw(obj)
            timeRaw = obj.TimeRaw_;
        end
        function velocityRaw = get.VelocityRaw(obj)
            velocityRaw = obj.VelocityRaw_;
        end
        function fluxParameterRaw = get.FluxParameterRaw(obj)
            fluxParameterRaw = obj.FluxParameterRaw_;
        end
        
        function timeDS = get.TimeDS(obj)
            switch obj.UpdateDownsamples
                case 'UpdateRequired'
                    obj.runDownsampling
            end
            timeDS = obj.TimeDS_;
        end
        function velocityDS = get.VelocityDS(obj)
            switch obj.UpdateDownsamples
                case 'UpdateRequired'
                    obj.runDownsampling
            end
            velocityDS = obj.VelocityDS_;
        end
        function fluxParameterDS = get.FluxParameterDS(obj)
            switch obj.UpdateDownsamples
                case 'UpdateRequired'
                    obj.runDownsampling
            end
            fluxParameterDS = obj.FluxParameterDS_;
        end
        
        function timeQC = get.TimeQC(obj)
            switch obj.UpdateQC
                case 'UpdateRequired'
                    obj.runQualityControl
            end
            timeQC = obj.TimeQC_;
        end
        function velocityQC = get.VelocityQC(obj)
            switch obj.UpdateQC
                case 'UpdateRequired'
                    obj.runQualityControl
            end
            velocityQC = obj.VelocityQC_;
        end
        function fluxParameterQC = get.FluxParameterQC(obj)
            switch obj.UpdateQC
                case 'UpdateRequired'
                    obj.runQualityControl
            end
            fluxParameterQC = obj.FluxParameterQC_;
        end
    end
    
    methods
        function time = get.Time(obj)
            time = reshape(cat(1,obj.TimeDownsampled,NaN(obj.WindowPaddingLength,1)),obj.WindowLength,obj.WindowN + 1);
        end
        function velocity = get.Velocity(obj)
            tmpVelocity	= permute(reshape(shiftdim(cat(1,obj.VelocityDownsampled,NaN(obj.WindowPaddingLength,3)),-1),obj.WindowLength,obj.WindowN + 1,[]),[1,3,2]);
        	velocity 	= NaN(obj.WindowLength,obj.WindowN + 1,3);
            for win = 1:obj.WindowN + 1
                velocity(:,win,:) = tmpVelocity(:,:,win)*obj.CoordinateSystemUnitVectors(:,:,win);
            end
        end
        function fluxParameter = get.FluxParameter(obj)
            fluxParameter = reshape(shiftdim(cat(1,obj.FluxParameterDownsampled,NaN(obj.WindowPaddingLength,obj.FluxParameterN)),-1),obj.WindowLength,obj.WindowN + 1,[]);
        end


        function frequency = get.Frequency(obj)
            frequency = round(1/(nanmean(diff(obj.TimeRaw))*24*60^2),6,'Significant')/obj.Downsamples;
        end
        function coordinateSystemUnitVectors = get.CoordinateSystemUnitVectors(obj)
            coordinateSystemUnitVectors = cat(3,obj.CoordinateSystemUnitVectorI,obj.CoordinateSystemUnitVectorJ,obj.CoordinateSystemUnitVectorK);
            coordinateSystemUnitVectors = permute(coordinateSystemUnitVectors,[3,2,1]);
        end
        function sampleN = get.SampleN(obj)
            sampleN = size(obj.TimeDownsampled,1);
        end
        function fluxParameterN = get.FluxParameterN(obj)
            fluxParameterN = size(obj.FluxParameterRaw,2);
        end
        function windowLength = get.WindowLength(obj)
            windowLength = floor(obj.Frequency*seconds(obj.Window));
        end
        function windowN = get.WindowN(obj)
            windowN = floor(size(obj.VelocityDownsampled,1)/obj.WindowLength);
        end
        function windowPaddingLength = get.WindowPaddingLength(obj)
            windowPaddingLength = obj.WindowLength - (obj.SampleN - obj.SampleWindowedN);
        end
        function sampleWindowedN = get.SampleWindowedN(obj)
            sampleWindowedN = obj.WindowLength*obj.WindowN;
        end
        function windowMask = get.WindowMask(obj)
            windowMask = ...
                obj.Time >= datenum(obj.StartTime) & ...
                obj.Time <= datenum(obj.EndTime);
        end
    end

    % Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags.
        function obj = set.TimeRaw(obj,value)
            obj.TimeRaw_   	= value;
%             obj.TimeDS     	= obj.TimeRaw;
            obj.UpdateDownsamples 	= 'UpdateRequired';
        end
        function obj = set.VelocityRaw(obj,value)
            obj.VelocityRaw_    = value;
%             obj.VelocityDS    	= obj.VelocityRaw;
            obj.UpdateDownsamples	= 'UpdateRequired';
        end
        function obj = set.FluxParameterRaw(obj,value)
            obj.FluxParameterRaw_	= value;
%             obj.FluxParameterDS   	= obj.FluxParameterRaw;
            obj.UpdateDownsamples   = 'UpdateRequired';
        end
        
        function obj = set.TimeDS(obj,value)
            obj.TimeDS_   	= value;
%             obj.TimeQC     	= obj.TimeDS;
            obj.FlagTime   	= obj.FlagTime.setNum(0,size(obj.TimeDS,1),size(obj.TimeDS,2));
            obj.UpdateQC 	= 'UpdateRequired';
        end
        function obj = set.VelocityDS(obj,value)
            obj.VelocityDS_     = value;
%             obj.VelocityQC    	= obj.VelocityDS;
            obj.FlagVelocity   	= obj.FlagVelocity.setNum(0,size(obj.VelocityDS,1),size(obj.VelocityDS,2));
            obj.UpdateQC        = 'UpdateRequired';
        end
        function obj = set.FluxParameterDS(obj,value)
            obj.FluxParameterDS_	= value;
%             obj.FluxParameterQC   	= obj.FluxParameterDS;
            obj.FlagFluxParameter 	= obj.FlagFluxParameter.setNum(0,size(obj.FluxParameterDS,1),size(obj.FluxParameterDS,2));
            obj.UpdateQC            = 'UpdateRequired';
        end
        
        function obj = set.TimeQC(obj,value)
            obj.TimeQC_         = value;
            obj.UpdateFluxes  	= 'UpdateRequired';
        end
        function obj = set.VelocityQC(obj,value)
            obj.VelocityQC_     = value;
            obj.UpdateFluxes 	= 'UpdateRequired';
        end
        function obj = set.FluxParameterQC(obj,value)
            obj.FluxParameterQC_	= value;
            obj.UpdateFluxes        = 'UpdateRequired';
        end
    end
  	methods
        function obj = set.SampleN(obj,value)
            if ~obj.Initialized
                obj.SampleN = value;
            else
                error('Dingi:GearKit:eddyFluxAnalysis:sampleNNotSetable',...
                      'SampleN is only set once during object construction.')
            end
        end
        function obj = set.Downsamples(obj,value)
            validateattributes(value,{'numeric'},{'scalar','integer','nonzero','positive'});
            obj.Downsamples = value;
%             if obj.Initialized
%                 obj.calculate(...
%                     'Downsample',                   true,...
%                     'RotateCoordinateSystem',       false,...
%                     'DetrendFluxParameter',         true,...
%                     'DetrendVerticalVelocity',      true);
%             end
        end
        function obj = set.CoordinateSystemRotationMethod(obj,value)
            obj.CoordinateSystemRotationMethod = validatestring(value,obj.ValidCoordinateSystemRotationMethods);
%             if obj.Initialized
%                 obj.calculate(...
%                     'Downsample',                   false,...
%                     'RotateCoordinateSystem',       true,...
%                     'DetrendFluxParameter',         false,...
%                     'DetrendVerticalVelocity',      true);
%             end
        end
        function obj = set.DetrendingMethod(obj,value)
            obj.DetrendingMethod = validatestring(value,obj.ValidDetrendingMethods);
%             if obj.Initialized
%                	obj.calculate(...
%                     'Downsample',                   false,...
%                     'RotateCoordinateSystem',       false,...
%                     'DetrendFluxParameter',         true,...
%                     'DetrendVerticalVelocity',      true);
%             end
        end
        function obj = set.Window(obj,value)
            obj.Window = value;
%             if obj.Initialized
%                	obj.calculate(...
%                     'Downsample',                   true,...
%                     'RotateCoordinateSystem',       true,...
%                     'DetrendFluxParameter',         true,...
%                     'DetrendVerticalVelocity',      true);
%             end
        end
    end

end
