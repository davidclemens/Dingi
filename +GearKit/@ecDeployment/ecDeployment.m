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
        function obj = ecDeployment(path)
            
            if nargin == 0
                path        = char.empty;
                gearType    = char.empty;
            elseif nargin == 1
                gearType    = 'EC';
            else
                error('GearKit:gearDeployment:ecDeployment:wrongNumberOfInputs',...
                    'Wrong number of inputs.\n')
            end
            
            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType);
            
            obj.timeOfInterestStart     = obj.timeOfInterestStart + duration(0,30,0);
            obj.timeOfInterestEnd       = obj.timeOfInterestEnd - duration(0,30,0);
           
            readInternalMeasuringDevices(obj);
            readAuxillaryMeasuringDevices(obj);
            assignMeasuringDeviceMountingData(obj);
            calibrateMeasuringDevices(obj);
            
            readAnalyticalSamples(obj);
        end
    end
    
	% methods in seperate files
    methods (Access = public)
       	runAnalysis(obj)
    end
    
    methods (Access = protected)
        readInternalMeasuringDevices(obj)
        planarFitCoordinateSystem(obj)
    end 
end