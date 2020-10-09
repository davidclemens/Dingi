classdef HardwareConfiguration < ECToolbox.NortekDataStructure
% HARDWARECONFIGURATION A NortekDataStructure common to all Nortek files.
%   The HARDWARECONFIGURATION class interprets and holds all information
%   of the hardware configureation data structure.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    properties
        serialNumber % Serial number of the Nortek instrument
        instrumentName % Instrument name of the Nortek instrument
        version 
        recorderInstalled % Flag if a recorder is installed
        compassInstalled % Flag if a compass is installed
        frequency % Frequency of the board (Hz)
        picCodeVersion % PIC code version number
        hardwareRevision % Hardware revision
        recorderSize % Recorder storage size (bytes)
        velocityRange % Velocity range
        firmwareVersion % Firmware version
    end
    properties (Hidden)
        structureId = 5 % Structure Id
    end
    
	methods
        function obj = HardwareConfiguration(NortekInstFileObj)      
        % HARDWARECONFIGURATION Constructs a Nortek Hardware Configuration data structure.
        % Create a HardwareConfiguration object that reads the Nortek Hardware
        % Configuration data structure (ID: 0x05 = 5) that is common to all Nortek
        % instruments.
        %
        % Syntax
        %   HardwareConfiguration = HARDWARECONFIGURATION(NortekInstFileObj)
        %
        %
        % Description
        %   HardwareConfiguration = HARDWARECONFIGURATION(NortekInstFileObj) reads 
        %        the Hardware Configuration data structure of a
        %        NortekInstrumentFile object and returns a HardwareConfiguration
        %        object.
        %
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   NortekInstFileObj - the NortekInstrumentFile object
        %       NortekInstrumentFile
        %       The NortekInstrumentFile object of which the Harware Configuration
        %       should be read.
        %
        %
        % Name-Value Pair Arguments
        %
        % 
        % See also
        %
        % Copyright 2020 David Clemens (dclemens@geomar.de)
            
            % call superclass constructor
            obj                         = obj@ECToolbox.NortekDataStructure(NortekInstFileObj);
            
            % return if data structure is not found in file
            if isempty(obj.structureStart)
                return
            end
            
            % read structure content
            [obj.serialNumber,...
             obj.instrumentName,...
             obj.version]               = obj.readSerialNumber(obj.structureBinaryData(5:18));
            [obj.recorderInstalled,...
             obj.compassInstalled]      = obj.readConfig(obj.structureBinaryData(19:20));
             obj.frequency              = ECToolbox.bytecast(obj.structureBinaryData(21:22),'L','uint16')*1e3;
             obj.picCodeVersion         = ECToolbox.bytecast(obj.structureBinaryData(23:24),'L','uint16');
             obj.hardwareRevision       = ECToolbox.bytecast(obj.structureBinaryData(25:26),'L','uint16');
             obj.recorderSize           = ECToolbox.bytecast(obj.structureBinaryData(27:28),'L','uint16')*2^16;
            [obj.velocityRange]        	= obj.readStatus(obj.structureBinaryData(29:30));
             obj.firmwareVersion        = obj.readFirmwareVersion(obj.structureBinaryData(43:46));
        end
        
    end
    
    methods (Access = private, Static)
        function [serialNumber,...
                  instrumentName,...
                  version] = readSerialNumber(bytes)
              
            ind     = find(bytes == 32 | any(bytes == [37,38,0],2));
            instrumentType  = native2unicode(bytes(1:ind(1) - 1)');
            serialNumber	= native2unicode(bytes(ind(1) + 1:ind(2) - 1)');
            version         = native2unicode(bytes(ind(2) + 2:end)');
            if ~isempty(regexp(instrumentType,'VEC','once'))
                instrumentName = 'Vector';
            end
        end
        
        function [recorderInstalled,...
                  compassInstalled] = readConfig(bytes)
            rawWords                    = ECToolbox.bytecast(bytes,'L','uint16');
            recorderInstalledOptions	= {'no','yes'};
            recorderInstalled       	= recorderInstalledOptions{1 + bitget(rawWords,1,'uint16')};
            compassInstalledOptions     = {'no','yes'};
            compassInstalled            = compassInstalledOptions{1 + bitget(rawWords,2,'uint16')};
        end
        
        function velocityRange = readStatus(bytes)
            rawWords                    = ECToolbox.bytecast(bytes,'L','uint16');
            velocityRangeOptions        = {'normal','high'};
            velocityRange               = velocityRangeOptions{1 + bitget(rawWords,1,'uint16')};
        end
        
        function [firmwareVersion] = readFirmwareVersion(bytes)
            firmwareVersion	= native2unicode(bytes');
        end
    end
end