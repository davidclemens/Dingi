classdef UserConfiguration < ECToolbox.NortekDataStructure
% USERCONFIGURATION A NortekDataStructure common to all Nortek files.
%   The USERCONFIGURATION class interprets and holds all information of the
%   user configureation data structure.
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    properties
        T1 % transmit pulse length
        T2 % blanking distance
        T3 % receive length
        T4 % time between pings
        T5 % time between burst sequences
        nPings % number of beam sequences per burst
        averageInterval % average interval (seconds)
        sampleRate % sampling rate (Hz)
        nBeams % number of beams
        timingControllerProfile % timing controller profile mode
        timingControllerMode % timing controller mode
        timingControllerPowerLevel % timing controller power level
        timingControllerSynchoutPosition % timing controller synchout position
        timingControllerSampleOnSynch % timing controller sample on synch
        timingControllerStartOnSynch % timing controller start on synch
        powerControlPowerLevel % power control power level
        A1_1 % not used
        B0_1 % not used
        B1_1 % not used
        compassUpdateRate % compass update rate (Hz)
        coordinateSystem % coordinate system
        nBins % number of cells
        binLength % cell size
        measurementInterval % measurement interval (seconds)
        deploymentName % recorder deployment name
        wrapMode % recorder wrap mode
        deploymentStartTime % deployment start time
        diagnosticInterval % time between diagnostics measurements (seconds)
        useUserSoundSpeed % use user specified sound speed
        diagnosticsOrWaveMode % diagnostics/wave mode
        analogOutputMode % analog output mode
        outputFormat % output format
        velocityScalingFaktor % velocity scaling
        serialOutput % serial output
        stage % stage
        outputPowerToAnalogInput % output power for analog input
        userSoundSpeedFaktor % user input sound speed adjustment factor
        diagnosticsNSamples % number of samples in diagnostics mode
        diagnosticsNBeamsPerCell % number of beams per cell number to measure in diagnostics mode
        nPingsDiag % number of pings in diagnostics/wave mode
        modeTestUseDSPFilter % correct using DSP filter
        modeTestFilterDataOutput % filter data output
        timeAnalogInput1 % timeline to use for analog input 1
        timeAnalogInput2 % timeline to use for analog input 2
        softwareVersion % software version
        salinity % salinity
        velocityAdjustmentTable % velocity adjustment table
        comments % file comments
        processingMethod % processing method
        waveMeasurementDataRate % wave measurement mode data rate
        waveMeasurementCellPosition % wave measurement mode wave cell position
        waveMeasurementDynamicPositionType % wave measurement mode type of dynamic position
        dynamicPercentagePositioning % percentage for wave cell positioning
        T1Wave % wave tranmit pulse
        T2Wave % fixed wave blanking distance
        T3Wave % wave measurement cell size
        nSamples % number of diagnostics/wave samples
        A1_2 % not used
        B0_2 % not used
        B1_2 % not used. For Vector it holds number of samples per burst
        nSamplesPerBurst % number of samples per burst
        analogOutputScaleFactor % analog output scale factor
        correlationThreshold % correlation threshold for resolving ambiguities
        transmitPulseLengthLag2 % transmit pulse length second lag
        qualConstant % stage match filster constants
    end
    properties (Hidden)
        structureId = 0
    end
    
	methods
        function obj = UserConfiguration(NortekFileObj)
        % USERCONFIGURATION Constructs a Nortek User Configuration data structure.
        % Create a UserConfiguration object that reads the Nortek Head
        % Configuration data structure (ID: 0x00 = 0) that is common to all Nortek
        % instruments.
        %
        % Syntax
        %   UserConfiguration = USERCONFIGURATION(NortekInstFileObj)
        %
        %
        % Description
        %   UserConfiguration = USERCONFIGURATION(NortekInstFileObj) reads 
        %        the User Configuration data structure of a
        %        NortekInstrumentFile object and returns a UserConfiguration
        %        object.
        %
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   NortekInstFileObj - the NortekInstrumentFile object
        %       NortekInstrumentFile
        %       The NortekInstrumentFile object of which the User Configuration
        %       should be read.
        %
        %
        % Name-Value Pair Arguments
        %
        % 
        % See also
        %
        % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
            
            % call superclass constructor
            obj                             = obj@ECToolbox.NortekDataStructure(NortekFileObj);
                        
            % return if data structure is not found in file
            if isempty(obj.structureStart)
                return
            end
            
            % read structure content            
             obj.T1                                     = ECToolbox.bytecast(obj.structureBinaryData(5:6),'L','uint16');
             obj.T2                                     = ECToolbox.bytecast(obj.structureBinaryData(7:8),'L','uint16');
             obj.T3                                     = ECToolbox.bytecast(obj.structureBinaryData(9:10),'L','uint16');
             obj.T4                                     = ECToolbox.bytecast(obj.structureBinaryData(11:12),'L','uint16');
             obj.T5                                     = ECToolbox.bytecast(obj.structureBinaryData(13:14),'L','uint16');
             obj.nPings                                 = ECToolbox.bytecast(obj.structureBinaryData(15:16),'L','uint16');
            [obj.averageInterval,...
             obj.sampleRate]                            = obj.readAverageInterval(obj.structureBinaryData(17:18));
             obj.nBeams                                 = ECToolbox.bytecast(obj.structureBinaryData(19:20),'L','uint16');
            [obj.timingControllerProfile,...
             obj.timingControllerMode,...
             obj.timingControllerPowerLevel,...
             obj.timingControllerSynchoutPosition,...
             obj.timingControllerSampleOnSynch,...
             obj.timingControllerStartOnSynch]          = obj.readTimingControllerMode(obj.structureBinaryData(21:22));
             obj.powerControlPowerLevel                 = obj.readPowerControl(obj.structureBinaryData(21:22));

             obj.compassUpdateRate                      = ECToolbox.bytecast(obj.structureBinaryData(31:32),'L','uint16');
             obj.coordinateSystem                       = obj.readCoordinateSystem(obj.structureBinaryData(33:34));
             obj.nBins                                  = ECToolbox.bytecast(obj.structureBinaryData(35:36),'L','uint16');
             obj.binLength                              = ECToolbox.bytecast(obj.structureBinaryData(37:38),'L','uint16');
             obj.measurementInterval                    = ECToolbox.bytecast(obj.structureBinaryData(39:40),'L','uint16');
             obj.deploymentName                         = obj.readDeploymentName(obj.structureBinaryData(41:46));
             obj.wrapMode                               = obj.readWrapMode(obj.structureBinaryData(47:48));
             obj.deploymentStartTime                    = ECToolbox.BCD2datetime(obj.structureBinaryData(49:54));
             obj.diagnosticInterval                     = ECToolbox.bytecast(obj.structureBinaryData(55:56),'L','uint16');
            [obj.useUserSoundSpeed,...
             obj.diagnosticsOrWaveMode,...
             obj.analogOutputMode,...
             obj.outputFormat,...
             obj.velocityScalingFaktor,...
             obj.serialOutput,...
             obj.stage,...
             obj.outputPowerToAnalogInput]              = obj.readMode(obj.structureBinaryData(59:60));
         
            [obj.timeAnalogInput1,...
             obj.timeAnalogInput2]                    	= obj.readAnalogInputAddress(obj.structureBinaryData(71:72));
         
            % TODO read remaining structure content
        end
    end
    
    methods (Access = private, Static)
        function [averageInterval,...
                  sampleRate] = readAverageInterval(bytes)
            averageInterval	= ECToolbox.bytecast(bytes,'L','uint16');
            sampleRate	= 512/averageInterval;
        end
        
        function [timingControllerProfile,...
                  timingControllerMode,...
                  timingControllerPowerLevel,...
                  timingControllerSynchoutPosition,...
                  timingControllerSampleOnSynch,...
                  timingControllerStartOnSynch] = readTimingControllerMode(bytes)
            rawWords                                = ECToolbox.bytecast(bytes,'L','uint16');
            timingControllerProfileOptions          = {'single','continuous'};
            timingControllerProfile                 = timingControllerProfileOptions{1 + bitget(rawWords,1,'uint16')};
            timingControllerModeOptions             = {'burst','continuous'};
            timingControllerMode                    = timingControllerModeOptions{1 + bitget(rawWords,2,'uint16')};
            timingControllerPowerLevelOptions       = {'High','High -','Low +','Low'};
            timingControllerPowerLevel          	= timingControllerPowerLevelOptions{1 + sum(2.^[1,0].*bitget(rawWords,5:6,'uint16'))};
            timingControllerSynchoutPositionOptions	= {'middle of sample','end of sample (Vector)'};
            timingControllerSynchoutPosition       	= timingControllerSynchoutPositionOptions{1 + bitget(rawWords,7,'uint16')};
            timingControllerSampleOnSynchOptions	= {'disabled','enabled, rising edge'};
            timingControllerSampleOnSynch       	= timingControllerSampleOnSynchOptions{1 + bitget(rawWords,8,'uint16')};
            timingControllerStartOnSynchOptions     = {'disabled','enabled, rising edge'};
            timingControllerStartOnSynch            = timingControllerStartOnSynchOptions{1 + bitget(rawWords,8,'uint16')};
        end
        
        function powerControlPowerLevel = readPowerControl(bytes)
            rawWords                          	= ECToolbox.bytecast(bytes,'L','uint16');
            powerControlPowerLevelOptions       = {'High','High -','Low +','Low'};
            powerControlPowerLevel          	= powerControlPowerLevelOptions{1 + sum(2.^[1,0].*bitget(rawWords,5:6,'uint16'))};
        end
        
        function deploymentName = readDeploymentName(bytes)
            deploymentName	= native2unicode(bytes');
        end
        
        function wrapMode = readWrapMode(bytes)
            rawWords                  	= ECToolbox.bytecast(bytes,'L','uint16');
            wrapModeOptions             = {'no wrap','wrap when full'};
            wrapMode                    = wrapModeOptions{1 + rawWords};
        end
        
        function coordinateSystem = readCoordinateSystem(bytes)
            rawWords                    = ECToolbox.bytecast(bytes,'L','uint16');
            coordinateSystemOptions   	= {'ENU','XYZ','BEAM'};
            coordinateSystem           	= coordinateSystemOptions{1 + rawWords};
        end
        
        function [useUserSoundSpeed,...
                  diagnosticsOrWaveMode,...
                  analogOutputMode,...
                  outputFormat,...
                  velocityScalingFaktor,...
                  serialOutput,...
                  stage,...
                  outputPowerToAnalogInput] = readMode(bytes)
            rawWords                        = ECToolbox.bytecast(bytes,'L','uint16');
            useUserSoundSpeedOptions        = {'no','yes'};
            useUserSoundSpeed               = useUserSoundSpeedOptions{1 + bitget(rawWords,1,'uint16')};
            diagnosticsOrWaveModeOptions    = {'disable','enable'};
            diagnosticsOrWaveMode           = diagnosticsOrWaveModeOptions{1 + bitget(rawWords,2,'uint16')};
            analogOutputModeOptions         = {'disable','enable'};
            analogOutputMode                = analogOutputModeOptions{1 + bitget(rawWords,3,'uint16')};
            outputFormatOptions             = {'Vector','ADV'};
            outputFormat                    = outputFormatOptions{1 + bitget(rawWords,4,'uint16')};
            velocityScalingFaktorOptions    = {1,0.1};
            velocityScalingFaktor           = velocityScalingFaktorOptions{1 + bitget(rawWords,5,'uint16')};
            serialOutputOptions             = {'disable','enable'};
            serialOutput                    = serialOutputOptions{1 + bitget(rawWords,6,'uint16')};
            stageOptions                    = {'disable','enable'};
            stage                           = stageOptions{1 + bitget(rawWords,8,'uint16')};
            outputPowerToAnalogInputOptions	= {'disable','enable'};
            outputPowerToAnalogInput       	= outputPowerToAnalogInputOptions{1 + bitget(rawWords,9,'uint16')};
        end
        
        function [timeAnalogInput1,...
                  timeAnalogInput2] = readAnalogInputAddress(bytes)
            rawWords             	= ECToolbox.bytecast(bytes,'L','uint16');
            analogInputAddressRaw   = logical([bitget(rawWords,16:-1:13,'uint16');bitget(rawWords,12:-1:9,'uint16');bitget(rawWords,8:-1:5,'uint16');bitget(rawWords,4:-1:1,'uint16')]);
            
            if sum(analogInputAddressRaw(:,4)) == 0
                analogInputAddressRaw(1,4)  = true;
            end
            if sum(analogInputAddressRaw(:,3)) == 0
                analogInputAddressRaw(1,3)  = true;
            end
            
            analogInputAddressOptions	= {'','Slow','Rapid','Rapid'}';
            timeAnalogInput1            = analogInputAddressOptions{analogInputAddressRaw(:,4)};
            timeAnalogInput2            = analogInputAddressOptions{analogInputAddressRaw(:,3)};
        end
    end
end