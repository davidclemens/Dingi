classdef HeadConfiguration < ECToolbox.NortekDataStructure
% HEADCONFIGURATION A NortekDataStructure common to all Nortek files.
%   The HEADCONFIGURATION class interprets and holds all information of the
%   head configureation data structure.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    properties
        pressureSensor % Flag if a pressure sensor is installed
        magnetometer % Flag if a magnetometer is installed
        tiltSensor % Flag if a tilt sensor is installed
        tiltSensorMounting % Direction the tilt sensor is mounted
        frequency % Head frequency (Hz)
        headType % Head type
        serialNumber % Head serial number
        systemData % System data
        nBeams % Number of beams
    end
    properties (Hidden)
        structureId = 4 % Structure Id
    end
    
	methods
        function obj = HeadConfiguration(NortekFileObj)      
        % HEADCONFIGURATION Constructs a Nortek Head Configuration data structure.
        % Create a HeadConfiguration object that reads the Nortek Head
        % Configuration data structure (ID: 0x04 = 4) that is common to all Nortek
        % instruments.
        %
        % Syntax
        %   HeadConfiguration = HEADCONFIGURATION(NortekInstFileObj)
        %
        %
        % Description
        %   HeadConfiguration = HEADCONFIGURATION(NortekInstFileObj) reads 
        %        the Head Configuration data structure of a
        %        NortekInstrumentFile object and returns a HeadConfiguration
        %        object.
        %
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   NortekInstFileObj - the NortekInstrumentFile object
        %       NortekInstrumentFile
        %       The NortekInstrumentFile object of which the Head Configuration
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
            obj                         = obj@ECToolbox.NortekDataStructure(NortekFileObj);
            
            % return if data structure is not found in file
            if isempty(obj.structureStart)
                return
            end
            
            % read structure content
            [obj.pressureSensor,...
             obj.magnetometer,...
             obj.tiltSensor,...
             obj.tiltSensorMounting]  	= obj.readConfig(obj.structureBinaryData(5:6));
             obj.frequency              = ECToolbox.bytecast(obj.structureBinaryData(7:8),'L','uint16')*1e3;
             obj.headType               = ECToolbox.bytecast(obj.structureBinaryData(9:10),'L','uint16');
             obj.serialNumber           = obj.readSerialNumber(obj.structureBinaryData(11:22));
             obj.systemData             = obj.readSystemData(obj.structureBinaryData(23:198));
             obj.nBeams                 = ECToolbox.bytecast(obj.structureBinaryData(221:222),'L','uint16');
        end 
    end
    
    methods (Access = private, Static)
        function [pressureSensor,...
                  magnetometer,...
                  tiltSensor,...
                  tiltSensorMounting]  	= readConfig(bytes)
            rawWords                    = ECToolbox.bytecast(bytes,'L','uint16');
            pressureSensorOptions       = {'no','yes'};
            pressureSensor              = pressureSensorOptions{1 + bitget(rawWords,1,'uint16')};
            magnetometerOptions         = {'no','yes'};
            magnetometer                = magnetometerOptions{1 + bitget(rawWords,2,'uint16')};
            tiltSensorOptions           = {'no','yes'};
            tiltSensor                  = tiltSensorOptions{1 + bitget(rawWords,3,'uint16')};
            tiltSensorMountingOptions  	= {'up','down'};
            tiltSensorMounting         	= tiltSensorMountingOptions{1 + bitget(rawWords,4,'uint16')};
        end
        
        function serialNumber = readSerialNumber(bytes)
            serialNumber	= native2unicode(bytes');
        end
        
        function systemData = readSystemData(bytes)
            rawWords  	= ECToolbox.bytecast(bytes,'L','uint16');
            systemData  = rawWords;
        end
    end
end