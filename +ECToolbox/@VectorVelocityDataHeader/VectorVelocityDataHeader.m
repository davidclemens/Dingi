classdef VectorVelocityDataHeader < ECToolbox.NortekDataStructure
% HEADCONFIGURATION A NortekDataStructure common to all Nortek files.
%   The HEADCONFIGURATION class interprets and holds all information of the
%   head configureation data structure.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    properties
        time
        nRecords
        noise
        correlation
    end
    properties (Hidden)
        structureId = 18 % Structure Id
    end
    
	methods
        function obj = VectorVelocityDataHeader(NortekFileObj)      
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
        	obj.time                    = ECToolbox.BCD2datetime(obj.structureBinaryData(5:10));
        	obj.nRecords                = ECToolbox.bytecast(obj.structureBinaryData(11:12),'L','uint16');
          	obj.noise                   = ECToolbox.bytecast(obj.structureBinaryData(13:15),'L','uint8');
            obj.correlation             = ECToolbox.bytecast(obj.structureBinaryData(17:19),'L','uint8');
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