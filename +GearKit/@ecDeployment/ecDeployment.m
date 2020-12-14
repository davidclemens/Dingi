classdef ecDeployment < GearKit.gearDeployment
% ECDEPLOYMENT Represents a Geomar BIGO deployment
%	The ECDEPLOYMENT class reads all data related to a single Geomar EC
%	deployment. The resulting object has plot, analysis and export methods.
%
% ECDEPLOYMENT Properties:
%
% ECDEPLOYMENT Methods:
%	ecDeployment - 
%
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

	properties
    end
    
	methods
        function obj = ecDeployment(path,varargin)
            
            if nargin == 0
                path = char.empty;
            end
            
            % parse Name-Value pairs
            optionName          = {'DebugLevel'}; % valid options (Name)
            optionDefaultValue  = {'Info'}; % default value (Value)
            [debugLevel]     	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            gearType    = 'EC';
                
            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType,...
                        'DebugLevel',       debugLevel);
            
            % support empty initializeation of gearDeployment subclasses
            if isempty(path)
                return
            end
            
            obj.timeOfInterestStart     = obj.timeOfInterestStart + duration(0,30,0);
            obj.timeOfInterestEnd       = obj.timeOfInterestEnd - duration(0,30,0);
           
            obj     = readInternalMeasuringDevices(obj);
            obj     = readAuxillaryMeasuringDevices(obj);
            obj     = applyMeasuringDeviceConfiguration(obj);
            obj     = assignMeasuringDeviceMountingData(obj);
            obj     = calibrateMeasuringDevices(obj);
            
            obj     = readAnalyticalSamples(obj);
        end
    end
    
	% methods in seperate files
    methods (Access = public)
       	obj	= runAnalysis(obj)
    end
    
    methods (Access = protected)
        obj = readInternalMeasuringDevices(obj)
        obj = planarFitCoordinateSystem(obj)
    end 
end