classdef eddyFluxAnalysis < AnalysisKit.analysis
% EDDYFLUXANALYSIS
%


% TODO:
%   (x) implement new velocityRaw, velocity, velocityRotated, etc. ...
%   (x) reshape timeseries so that dim2 represents the windows to make per-
%       window calculations easier.
%   (x) implement despiking.
%   ( ) implement time-shift correction between velocity and fluxParameters
%   ( ) implement custom moving window size for detrending method 'moving
%       mean'.
%   (x) implement subsampling of the original dataset
%   (x) implement setting start and end time of the analysis
%   (x) implement get & set property access methods
%   (x) implement flags to track which data points were manipulated
%   (x) implement NaNs
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
        % Stack depth 1 (Raw data)
        TimeRaw (:,1) double % Raw Time (datenum)
        VelocityRaw (:,3) double % Raw velocity (m/s)
        FluxParameterRaw double % Raw flux parameter data

        % Stack depth 2 (Downsampling)
        TimeDS (:,1) double % Downsampled time (datenum)
        VelocityDS (:,3) double % Downsampled velocity (m/s)
        FluxParameterDS double % Downsampled flux parameter data

        % Stack depth 3 (Quality control)
        TimeQC (:,1) double % Quality controlled time (datenum)
        VelocityQC (:,3) double % Quality controlled velocity (m/s)
        FluxParameterQC double % Quality controlled flux parameter data
        
        % Stack depth 4 (Rotation & time segragation)
        CoordinateSystemUnitVectorI (:,3) double
        CoordinateSystemUnitVectorJ (:,3) double
        CoordinateSystemUnitVectorK (:,3) double
        TimeRS double % Segregated time
        VelocityRS double % Rotated & segregated velocity (m/s)
        VelocityRSenu double % Rotated & segregated velocity (m/s) in ENU coordinate system
        FluxParameterRS double % Segregated flux parameter
        
        % Stack depth 5 (Detrending)
        VelocityDT double % Detrended velocity (m/s)
        FluxParameterDT double % Detrended flux parameter data
        VelocityDTMean double % Velocity mean value (m/s)
        FluxParameterDTMean double % Flux parameter mean value
    end
    properties
        SNRDS (:,3) double % Downsampled signal to noise ratio
        BeamCorrelationDS (:,3) double % Downsampled beam correlation

        FlagDataset DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDatasetFlag',1,1)
        FlagTime DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
        FlagVelocity DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
        FlagFluxParameter DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag')
    end
    properties
        WindowDuration duration % Window or averaging interval (duration)
        DespikeMethod char = 'none' % Despiking method
        Downsamples = 1 % Number of downlsamples.
        CoordinateSystemRotationMethod char = 'planar fit'
        DetrendingMethod char = 'moving mean' % Detrending method
        ReplaceMethod char = 'linear' % Method to use to replace rejected data points

        StartTime (1,1) datetime
        EndTime (1,1) datetime

        FluxParameterTimeShift (1,:) double % Time shift of the flux parameter (# of samples)

        ObstacleAngles (:,1) double % The anticlockwise angle(s) seen from above the lander starting with 0° on the ADV x-axis, where obstacles (legs, sensors, etc.) are located.
        ObstacleSectorWidth (1,1) double = 5 % Sector width in degrees
        
        PitchRollHeading
    end

    % Backend
    properties (Access = 'private')
        % Stack depth 1
        TimeRaw_ (:,1) double % Raw Time (datenum)
        VelocityRaw_ (:,3) double % Raw velocity (m/s)
        FluxParameterRaw_ double % Raw flux parameter data

        % Stack depth 2
        TimeDS_ (:,1) double % Downsampled time (datenum)
        VelocityDS_ (:,3) double % Downsampled velocity (m/s)
        FluxParameterDS_ double % Downsampled flux parameter data

        % Stack depth 3
        TimeQC_ (:,1) double % Quality controlled time (datenum)
        VelocityQC_ (:,3) double % Quality controlled velocity (m/s)
        FluxParameterQC_ double % Quality controlled flux parameter data
        
        % Stack depth 4
        CoordinateSystemUnitVectorI_ (:,3) double
        CoordinateSystemUnitVectorJ_ (:,3) double
        CoordinateSystemUnitVectorK_ (:,3) double
        TimeRS_ double % Segregated time
        VelocityRS_ double % Rotated & segregated velocity (m/s)
        VelocityRSenu_ double % Rotated & segregated velocity (m/s) in ENU coordinate system
        FluxParameterRS_ double % Segregated flux parameter
        
        % Stack depth 5
        VelocityDT_ double % Detrended velocity (m/s)
        FluxParameterDT_ double % Detrended flux parameter data
        VelocityDTMean_ double % Velocity mean value (m/s)
        FluxParameterDTMean_ double % Flux parameter mean value
    end
    properties (Dependent) %Access = 'private', 
        UpdateStack
    end
    properties (Access = 'private')
        UpdateStack_ = 2.*ones(5,1) % Initialize as update required
    end
    properties %(Hidden)
        DetrendingFunction
        Initialized logical = false
    end
    properties (Dependent)
        Frequency (1,1) double % Frequency (Hz)

       	Time % Time (datenum). Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window]. The Size is windowLength x windowN.
        Velocity % Velocity (m/s). Rotated according to the CoordinateSystemRotationMethod. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[vx,vy,vz]]. The Size is windowLength x windowN x 3.
        FluxParameter % flux parameter. Padded by NaNs to fit an integer multiple of windowLength. The Shape is [sample,window,[fluxParameters]]. The Size is windowLength x windowN x fluxParameterN.
    end
    properties (Dependent) %Hidden
        NFluxParameters (1,1) double % Number of flux parameters
        NSamplesRaw (1,1) double % Number of raw samples
        NSamplesDS (1,1) double % Number of downsampled samples
        NSamplesPerWindow (1,1) double % Number of samples in each window
        NSamplesInWindows (1,1) double % Total number of samples that are covered by a window.
        NSamplesWindowsPadding (1,1) double % Padding length (samples) of the last incomplete window.
        NWindows (1,1) double % Number of full windows in timeseries
        WindowMask % Windows that fully lie within the [StartTime,EndTime] interval
        CoordinateSystemUnitVectors
    end
    properties (Hidden, Constant)
        ValidCoordinateSystemRotationMethods = {'planar fit'};
        ValidReplaceMethods = {'none','linear'};
        ValidDetrendingMethods = {'mean removal','linear','moving mean'};
        ValidDespikingMethods = {'none','phase-space thresholding'};
    end
    methods
        function obj = eddyFluxAnalysis(time,velocity,fluxParameter,varargin)

            import internal.stats.parseArgs
            import GearKit.ecDeployment

            % parse Name-Value pairs
            optionName          = {'SNR','BeamCorrelation','WindowDuration','Downsamples','CoordinateSystemRotationMethod','DetrendingMethod','DespikeMethod','Start','End','ObstacleAngles','Parent','PitchRollHeading'}; % valid options (Name)
            optionDefaultValue  = {[],[],duration(0,30,0),2,'planar fit','moving mean','none',[],[],[],ecDeployment,zeros(1,3)}; % default value (Value)
            [snr,...
             beamCorrelation,...
             windowDuration,...
             downsamples,...
             coordinateSystemRotationMethod,...
             detrendingMethod,...
             despikeMethod,...
             startTime,...
             endTime,...
             obstacleAngles,...
             parent,...
             pitchRollHeading,...
             ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % call superclass constructor
            obj = obj@AnalysisKit.analysis();

            % populate properties
            validateattributes(parent,{'GearKit.ecDeployment'},{});
            obj.Parent                          = parent;
            obj.WindowDuration                  = windowDuration;
            obj.Downsamples                     = downsamples;
            obj.CoordinateSystemRotationMethod	= validatestring(coordinateSystemRotationMethod,obj.ValidCoordinateSystemRotationMethods);
            obj.DetrendingMethod                = validatestring(detrendingMethod,obj.ValidDetrendingMethods);
            obj.DespikeMethod                   = validatestring(despikeMethod,obj.ValidDespikingMethods);
            obj.ObstacleAngles                  = obstacleAngles;
            obj.PitchRollHeading                = pitchRollHeading;

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
        end
    end

	% Methods in other files
    methods
        varargout = checkUpdateStack(obj,stackDepth)
        varargout = runDownsampling(obj)
        varargout = runQualityControl(obj)
        varargout = runCoordinateSystemRotation(obj)
        varargout = runFootprintAnalysis(obj)
        varargout = despike(obj)
        varargout = planarFitCoordinateSystem(obj)
        varargout = detrend(obj,varargin)
        varargout = timeShift(obj)
        varargout = calculateCospectrum(obj)
        varargout = rotateCoordinateSystem(obj)
        func = dGetDetrendingFunction(obj,detrendingOptions)
        
        varargout = plot(obj,varargin)
        varargout = plotSpectra(obj,window)
        varargout = plotQualityControlStatistics(obj,fig)
        varargout = plotQualityControl(obj,fig,datasetName,varargin)
        varargout = plotTracerPath(obj,fig,varargin)
    end
    methods (Access = 'private')
        varargout = qualityControlRawData(obj)
        varargout = despikePST(obj,datasetName)
        varargout = replaceData(obj,flag)
        varargout = rotateSegregateScalars(obj)
        checkForMissingData(obj)
        checkForAbsoluteLimits(obj)
        checkForSpikes(obj)
        checkForCurrentObstructions(obj)
        checkForAmplitudeResolution(obj)
        checkForDropouts(obj)
        checkForSignalToNoiseRatio(obj)
        checkForBeamCorrelation(obj)
        checkForHighCurrentRotation(obj)
        checkForLowHorizontalVelocity(obj)
    end

    methods (Static, Access = 'private')
        % methods in other files
        y = downsample(x,N)
        [y,meanValue] = detrendMeanRemoval(x)
        [y,meanValue] = detrendLinear(x)
        [y,meanValue] = detrendMovingMean(x,window)

        [k,b0] = csPlanarFitUnitVectorK(U1)
        [i,j] = csPlanarFitUnitVectorIJ(U1,k)

        varargout = plotPhaseSpace(x,dx,d2x,uniCrit,theta)
        
        ENU = xyz2enu(XYZ,pitch,roll,heading)
    end

    % Get methods
    methods
        % Frontend/Backend interface
        function timeRaw = get.TimeRaw(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            timeRaw = obj.TimeRaw_;
        end
        function velocityRaw = get.VelocityRaw(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            velocityRaw = obj.VelocityRaw_;
        end
        function fluxParameterRaw = get.FluxParameterRaw(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            fluxParameterRaw = obj.FluxParameterRaw_;
        end

        function timeDS = get.TimeDS(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            timeDS = obj.TimeDS_;
        end
        function velocityDS = get.VelocityDS(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            velocityDS = obj.VelocityDS_;
        end
        function fluxParameterDS = get.FluxParameterDS(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            fluxParameterDS = obj.FluxParameterDS_;
        end

        function timeQC = get.TimeQC(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            timeQC = obj.TimeQC_;
        end
        function velocityQC = get.VelocityQC(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            velocityQC = obj.VelocityQC_;
        end
        function fluxParameterQC = get.FluxParameterQC(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            fluxParameterQC = obj.FluxParameterQC_;
        end
        
        function coordinateSystemUnitVectorI = get.CoordinateSystemUnitVectorI(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            coordinateSystemUnitVectorI = obj.CoordinateSystemUnitVectorI_;            
        end
        function coordinateSystemUnitVectorJ = get.CoordinateSystemUnitVectorJ(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            coordinateSystemUnitVectorJ = obj.CoordinateSystemUnitVectorJ_;            
        end
        function coordinateSystemUnitVectorK = get.CoordinateSystemUnitVectorK(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            coordinateSystemUnitVectorK = obj.CoordinateSystemUnitVectorK_;            
        end
        function timeRS = get.TimeRS(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            timeRS = obj.TimeRS_;  
        end
        function velocityRS = get.VelocityRS(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            velocityRS = obj.VelocityRS_;  
        end
        function velocityRSenu = get.VelocityRSenu(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            velocityRSenu = obj.VelocityRSenu_;  
        end
        function fluxParameterRS = get.FluxParameterRS(obj)
            stackDepth = 4;
            obj.checkUpdateStack(stackDepth)
            fluxParameterRS = obj.FluxParameterRS_;  
        end
        
        function velocityDT = get.VelocityDT(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            velocityDT = obj.VelocityDT_;  
        end
        function fluxParameterDT = get.FluxParameterDT(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxParameterDT = obj.FluxParameterDT_;  
        end
        function velocityDTMean = get.VelocityDTMean(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            velocityDTMean = obj.VelocityDTMean_;  
        end
        function fluxParameterDTMean = get.FluxParameterDTMean(obj)
            stackDepth = 5;
            obj.checkUpdateStack(stackDepth)
            fluxParameterDTMean = obj.FluxParameterDTMean_;  
        end
        
        function updateStack = get.UpdateStack(obj)
            updateStack = obj.UpdateStack_;
        end
    end

    methods
        function frequency = get.Frequency(obj)
            frequency = round(1/(nanmean(diff(obj.TimeRaw))*24*60^2),6,'Significant')/obj.Downsamples;
        end
        function coordinateSystemUnitVectors = get.CoordinateSystemUnitVectors(obj)
            coordinateSystemUnitVectors = cat(3,obj.CoordinateSystemUnitVectorI,obj.CoordinateSystemUnitVectorJ,obj.CoordinateSystemUnitVectorK);
            coordinateSystemUnitVectors = permute(coordinateSystemUnitVectors,[3,2,1]);
        end
        
        function nFluxParameters = get.NFluxParameters(obj)
            nFluxParameters = size(obj.FluxParameterRaw_,2);
        end
        function nSamplesRaw = get.NSamplesRaw(obj)
            nSamplesRaw = size(obj.TimeRaw_,1);
        end
        function nSamplesDS = get.NSamplesDS(obj)
            nSamplesDS = size(obj.TimeDS_,1);
        end
        function nSamplesPerWindow = get.NSamplesPerWindow(obj)
            nSamplesPerWindow = floor(obj.Frequency*seconds(obj.WindowDuration));
        end
        function nWindows = get.NWindows(obj)
            nWindows = floor(obj.NSamplesDS/obj.NSamplesPerWindow);
        end
        function nSamplesInWindows = get.NSamplesInWindows(obj)
            nSamplesInWindows = obj.NSamplesPerWindow*obj.NWindows;
        end
        function nSamplesWindowsPadding = get.NSamplesWindowsPadding(obj)
            nSamplesWindowsPadding = obj.NSamplesPerWindow - (obj.NSamplesDS - obj.NSamplesInWindows);
        end
        function windowMask = get.WindowMask(obj)
            windowMask = ...
                obj.TimeQC >= datenum(obj.StartTime) & ...
                obj.TimeQC <= datenum(obj.EndTime);
        end
    end

    % Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags.
        function obj = set.TimeRaw(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.TimeRaw_                = value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        function obj = set.VelocityRaw(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.VelocityRaw_            = value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end
        function obj = set.FluxParameterRaw(obj,value)
            stackDepth                  = 1;
            obj.UpdateStack(stackDepth) = 1; % Set to 'Updating'
            obj.FluxParameterRaw_       = value;
            obj.UpdateStack(stackDepth) = 0; % Set to 'Updated'
        end

        function obj = set.TimeDS(obj,value)
            obj.TimeDS_             = value;
            obj.FlagTime            = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag',obj.NSamplesDS,1);
        end
        function obj = set.VelocityDS(obj,value)
            obj.VelocityDS_        	= value;
            obj.FlagVelocity        = DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag',obj.NSamplesDS,3);
        end
        function obj = set.FluxParameterDS(obj,value)
            obj.FluxParameterDS_	= value;
            obj.FlagFluxParameter 	= DataKit.bitflag('AnalysisKit.Metadata.eddyFluxAnalysisDataFlag',obj.NSamplesDS,obj.NFluxParameters);
        end

        function obj = set.TimeQC(obj,value)
            obj.TimeQC_                         = value;
        end
        function obj = set.VelocityQC(obj,value)
            obj.VelocityQC_                     = value;
        end
        function obj = set.FluxParameterQC(obj,value)
            obj.FluxParameterQC_                = value;
        end
        
        function obj = set.CoordinateSystemUnitVectorI(obj,value)
            obj.CoordinateSystemUnitVectorI_  	= value;
        end
        function obj = set.CoordinateSystemUnitVectorJ(obj,value)
            obj.CoordinateSystemUnitVectorJ_  	= value;
        end
        function obj = set.CoordinateSystemUnitVectorK(obj,value)
            obj.CoordinateSystemUnitVectorK_  	= value;
        end
        function obj = set.TimeRS(obj,value)
            obj.TimeRS_  	= value;
        end
        function obj = set.VelocityRS(obj,value)
            obj.VelocityRS_  	= value;
        end
        function obj = set.VelocityRSenu(obj,value)
            obj.VelocityRSenu_ 	= value;
        end
        function obj = set.FluxParameterRS(obj,value)
            obj.FluxParameterRS_  	= value;
        end
        
        function obj = set.VelocityDT(obj,value)
            obj.VelocityDT_         = value;
        end
        function obj = set.FluxParameterDT(obj,value)
            obj.FluxParameterDT_	= value;
        end
        function obj = set.VelocityDTMean(obj,value)
            obj.VelocityDTMean_  	= value;
        end
        function obj = set.FluxParameterDTMean(obj,value)
            obj.FluxParameterDTMean_	= value;
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
  	methods
        function obj = set.Downsamples(obj,value)
            validateattributes(value,{'numeric'},{'scalar','integer','positive','nonnan','finite'});
            if ~isequal(obj.Downsamples,value)
                obj.Downsamples = value;
                stackDepth = 2;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
        function obj = set.ReplaceMethod(obj,value)
            value = validatestring(value,obj.ValidReplaceMethods);
            if ~isequal(obj.ReplaceMethod,value)
                obj.ReplaceMethod = value;
                stackDepth = 3;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
        function obj = set.DespikeMethod(obj,value)
            value = validatestring(value,obj.ValidDespikingMethods);
            if ~isequal(obj.DespikeMethod,value)
                obj.DespikeMethod = value;
                stackDepth = 3;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
        function obj = set.CoordinateSystemRotationMethod(obj,value)
            value = validatestring(value,obj.ValidCoordinateSystemRotationMethods);
            if ~isequal(obj.CoordinateSystemRotationMethod,value)
                stackDepth = 4;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
        function obj = set.DetrendingMethod(obj,value)
            value = validatestring(value,obj.ValidDetrendingMethods);
            if ~isequal(obj.DetrendingMethod,value)
                stackDepth = 5;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
        function obj = set.WindowDuration(obj,value)
            validateattributes(value,{'duration'},{'scalar'});
            validateattributes(seconds(value),{'numeric'},{'positive','nonnan','finite'});
            if ~isequal(obj.WindowDuration,value)
                obj.WindowDuration = value;
                stackDepth = 4;
                obj.UpdateStack(stackDepth) = 2; % Set to UpdateRequired
            end
        end
    end
end
