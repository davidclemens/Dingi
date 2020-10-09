classdef NortekVecFile < ECToolbox.NortekInstrumentFile
% NORTEKVECFILE Class for a Nortek binary .vec file
%   The NORTEKVECFILE class has methods to read the binary data.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    properties
        vectorProbeCheckData
        vectorVelocityDataHeader
        nSamplesSlow % Number of slow samples
        nSamplesRapid % Number of rapid samples
        sampleRateSlow % Sample rate of the slow sensors (Hz)
        sampleRateRapid % Sample rate of the rapid sensors (Hz)
    end
    properties (Constant)
        instrumentName = 'Vector'; % Name of Nortek instrument
        instrumentType = 'Velocitometer'; % Type of Nortek instrument
    end
    properties (Constant, Hidden)
        instrumentFileExtension = '.vec'
    end
    properties (Dependent)
        timeSlow % Time of the slow sensors
        timeRapid % Time of the rapid sensors
        timeSlowRelative % Relative time of the slow sensors (h)
        timeRapidRelative % Relative time of the rapid sensors (h)
        ensembleCount % Ensemble count (rapid)
        velocity % Velocity (m/s, rapid)
        velocityU % Velocity component u (m/s, rapid)
        velocityV % Velocity component u (m/s, rapid)
        velocityW % Velocity component u (m/s, rapid)
        amplitude % Amplitude for all beams (counts, rapid)
        amplitudeBeam1 % Amplitude for beam1 (counts, rapid)
        amplitudeBeam2 % Amplitude for beam2 (counts, rapid)
        amplitudeBeam3 % Amplitude for beam3 (counts, rapid)
        correlation % Correlation for all beams (%, rapid)
        correlationBeam1 % Correlation for beam1 (%, rapid)
        correlationBeam2 % Correlation for beam2 (%, rapid)
        correlationBeam3 % Correlation for beam3 (%, rapid)
        pressure % Pressure (dbar, rapid)
        analogInput1 % AnalogInput1 (V, rapid)
        analogInput2 % AnalogInput2 (V, rapid)
        compass % Heading, pitch & roll (°ENU, slow)
        heading % Compass heading (°ENU, slow)
        pitch % Compass pitch (°ENU, slow)
        roll % Compass roll (°ENU, slow)
        temperature % Temperature (°C, slow)
        batteryVoltage % Battery voltage (V, slow)
        soundSpeed % Sound speed (m/s, slow)
        errorCode % Error codes (slow)
        statusCode % Status codes (slow)
        timeseriesVelocity % Velocity as timeseries object
        timeseriesAmplitude % Amplitude as timeseries object
        timeseriesCorrelation % Correlation as timeseries object
        timeseriesPressure % Pressure as timeseries object
        timeseriesAnalogInput1 % AnalogInput1 as timeseries object
        timeseriesAnalogInput2 % AnalogInput2 as timeseries object
        timeseriesCompass % Compass as timeseries object
        timeseriesTemperature % Temperature as timeseries object
        timeseriesBatteryVoltage % Battery voltage as timeseries object
        timeseriesSoundSpeed % Sound speed as timeseries object
    end
    properties (Hidden)
        plotHandles = struct('hfig',gobjects(0),'hsp',gobjects(0))
        data2TimeLink
        dataMetadata
        timeMetadata
    end
    methods
        function obj = NortekVecFile(fullFilename,varargin)
        % NORTEKVECFILE Constructs a NortekVecFile object from a .vec file.
        % Create a NortekVecFile object that reads a Nortek Vector file (.vec) and
        % allows to extract specific information
        %
        % Syntax
        %   NortekVecFile = NORTEKVECFILE(filename)
        %   NortekVecFile = NORTEKVECFILE(__,Name,Value)
        %
        % Description
        %   NortekVecFile = NORTEKVECFILE(filename) reads the Nortek .vec file 
        %       specified in filename and returns a NORTEKVECFILE object.
        %
        %   NortekVecFile = NORTEKVECFILE(__,Name,Value) specifies additional 
        %       parameters for the NortekVecFile using one or more name-value pair 
        %       arguments as listed below.
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   filename - full file name to .vec file
        %       The full filename to the Nortek .vec file to be read.
        %
        %
        % Name-Value Pair Arguments
        %   DebugLevel - Level of debug information
        %       'Info' (default) | 'Error' | 'Warning' | 'Verbose'
        %           Sets the debug level which controls the level of information
        %           that is output to the command window.
        %   Reindex - Reindex instrument file
        %       false (default) | true
        %           Set to true if the file should be reindexed.
        %
        % 
        % See also
        %
        % Copyright 2020 David Clemens (dclemens@geomar.de)
        
            % call superclass constructor
            obj	= obj@ECToolbox.NortekInstrumentFile(fullFilename,varargin{:});

            obj.data2TimeLink               = table({'Slow';'Rapid'},...
                                                    {{'compass','temperature','batteryVoltage','soundSpeed'};{'velocity','amplitude','correlation','pressure','analogInput1','analogInput2'}},...
                                                    {{{'heading','pitch','roll'},{'temperature'},{'batteryVoltage'},{'soundSpeed'}};{{'u','v','w'},{'beam1','beam2','beam3'},{'beam1','beam2','beam3'},{'pressure'},{'analogInput1'},{'analogInput2'}}},...
                                                    {{'°','°C','V','m/s'};{'m/s','counts','%','dbar','V','V'}},...
                                                'VariableNames',    {'time','data','subdata','units'});
            
            obj.dataMetadata                = cell2table(...
                                              {'compass',           	'Slow',     '°';...
                                               'eading',                'Slow',     '°N';...
                                               'pitch',                 'Slow',     '°';...
                                               'roll',                  'Slow',     '°';...
                                               'temperature',       	'Slow',     '°C';...
                                               'batteryVoltage',    	'Slow',     'V';...
                                               'soundSpeed',        	'Slow',     'm s^{-1}';...
                                               'velocity',          	'Rapid',    'm s^{-1}';...
                                               'velocityU',          	'Rapid',    'm s^{-1}';...
                                               'velocityV',          	'Rapid',    'm s^{-1}';...
                                               'velocityW',          	'Rapid',    'm s^{-1}';...
                                               'amplitude',             'Rapid',    '';...
                                               'amplitudeBeam1',      	'Rapid',    '';...
                                               'amplitudeBeam2',      	'Rapid',    '';...
                                               'amplitudeBeam3',      	'Rapid',    '';...
                                               'correlation',           'Rapid',    '%';...
                                               'correlationBeam1',     	'Rapid',    '%';...
                                               'correlationBeam2',     	'Rapid',    '%';...
                                               'correlationBeam3',     	'Rapid',    '%';...
                                               'pressure',              'Rapid',    'dbar';...
                                               'analogInput1',         	'Rapid',    'V';...
                                               'analogInput2',         	'Rapid',    'V'},...
                                               'VariableNames',...
                                              {'parameter',             'time',     'unit'});
            
            % read Vector Probe Check Data
            obj.vectorProbeCheckData        = ECToolbox.VectorProbeCheckData(obj);
            
            % read Vector Velocity Data Header
            obj.vectorVelocityDataHeader	= ECToolbox.VectorVelocityDataHeader(obj);
            
            obj.nSamplesSlow    = size(obj.compass,1);
            obj.nSamplesRapid   = size(obj.velocity,1);
            obj.sampleRateSlow  = obj.UserConfiguration.compassUpdateRate;
            obj.sampleRateRapid = obj.UserConfiguration.sampleRate;
        end
        
        function timeSlow = get.timeSlow(obj)
            timeSlow = obj.getTimeSlow;
        end
        function timeRapid = get.timeRapid(obj)
            timeRapid = obj.getTimeRapid;
        end
        function timeSlowRelative = get.timeSlowRelative(obj)
            timeSlowRelative = obj.getTimeSlowRelative;
        end
        function timeRapidRelative = get.timeRapidRelative(obj)
            timeRapidRelative = obj.getTimeRapidRelative;
        end
        
        function ensembleCount = get.ensembleCount(obj)
            ensembleCount = obj.getEnsembleCount;
        end
        function velocity = get.velocity(obj)
            velocity = obj.getVelocity;
        end
        function velocityU = get.velocityU(obj)
            velocityU = obj.velocity(:,1);
        end
        function velocityV = get.velocityV(obj)
            velocityV = obj.velocity(:,2);
        end
        function velocityW = get.velocityW(obj)
            velocityW = obj.velocity(:,3);
        end
        function amplitude = get.amplitude(obj)
            amplitude   	= obj.getAmplitude;
        end
        function amplitudeBeam1 = get.amplitudeBeam1(obj)
            amplitudeBeam1 = obj.amplitude(:,1);
        end
        function amplitudeBeam2 = get.amplitudeBeam2(obj)
            amplitudeBeam2 = obj.amplitude(:,2);
        end
        function amplitudeBeam3 = get.amplitudeBeam3(obj)
            amplitudeBeam3 = obj.amplitude(:,3);
        end
        function correlation = get.correlation(obj)
            correlation   	= obj.getCorrelation;
        end
        function correlationBeam1 = get.correlationBeam1(obj)
            correlationBeam1 = obj.correlation(:,1);
        end
        function correlationBeam2 = get.correlationBeam2(obj)
            correlationBeam2 = obj.correlation(:,2);
        end
        function correlationBeam2 = get.correlationBeam3(obj)
            correlationBeam2 = obj.correlation(:,3);
        end
        function pressure = get.pressure(obj)
            pressure        = obj.getPressure;
        end
        function analogInput1 = get.analogInput1(obj)
            analogInput1  	= obj.getAnalogInput1;
        end
        function analogInput2 = get.analogInput2(obj)
            analogInput2  	= obj.getAnalogInput2;
        end
        
        function compass = get.compass(obj)
            compass = obj.getCompass;
        end
        function heading = get.heading(obj)
            heading = obj.compass(:,1);
        end
        function pitch = get.pitch(obj)
            pitch = obj.compass(:,2);
        end
        function roll = get.roll(obj)
            roll = obj.compass(:,3);
        end
        function temperature = get.temperature(obj)
            temperature  	= obj.getTemperature;
        end
        function batteryVoltage = get.batteryVoltage(obj)
            batteryVoltage	= obj.getBatteryVoltage;
        end
        function soundSpeed = get.soundSpeed(obj)
            soundSpeed      = obj.getSoundSpeed;
        end
        function errorCode = get.errorCode(obj)
            errorCode       = obj.getErrorCode;
        end
        function statusCode = get.statusCode(obj)
            statusCode      = obj.getStatusCode;
        end
        
        function obj = set.dataMetadata(obj,value)
            [split,match]           = regexp(value.parameter,'[A-Z0-9]','split','match');
            
            nParameters             = size(value,1);
            parameterString         = cell(nParameters,1);
            
            for ii = 1:nParameters
                parameterString{ii} = lower(strjoin(reshape(cat(1,[{''},repmat({' '},1,numel(split{ii}) - 1)],[{''},match{ii}],split{ii}),[],1)',''));
            end
            value.parameterString	= parameterString;
            

            mask	= ismember(value.parameter,'analogInput1');
            if ~isempty(obj.UserConfiguration.timeAnalogInput1)
                value.time{mask} = obj.UserConfiguration.timeAnalogInput1;
            else
                value(mask,:)	= [];
            end
            
            mask	= ismember(value.parameter,'analogInput2');
            if ~isempty(obj.UserConfiguration.timeAnalogInput1)
                value.time{mask} = obj.UserConfiguration.timeAnalogInput2;
            else
                value(mask,:)	= [];
            end
            
            obj.dataMetadata       	= value;
        end
        
        % METHODS (in seperate files)        
        timeSlow            = getTimeSlow(obj)
        timeRapid           = getTimeRapid(obj)
        timeSlowRelative  	= getTimeSlowRelative(obj)
        timeRapidRelative	= getTimeRapidRelative(obj)
        
        ensembleCount       = getEnsembleCount(obj)
        velocity            = getVelocity(obj)
        amplitude           = getAmplitude(obj)
        correlation         = getCorrelation(obj)
        pressure            = getPressure(obj)
        analogInput1        = getAnalogInput1(obj)
        analogInput2        = getAnalogInput2(obj)
        
        compass             = getCompass(obj)
        temperature         = getTemperature(obj)
        batteryVoltage      = getBatteryVoltage(obj)
        soundSpeed          = getSoundSpeed(obj)
        errorCode           = getErrorCode(obj)
        statusCode          = getStatusCode(obj)
    end
end