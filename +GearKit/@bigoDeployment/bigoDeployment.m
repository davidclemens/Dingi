classdef bigoDeployment < GearKit.gearDeployment
% BIGODEPLOYMENT Represents a Geomar BIGO deployment
%	The BIGODEPLOYMENT class reads all data related to a single Geomar BIGO
%	deployment. The resulting object has plot, analysis and export methods.
%
% BIGODEPLOYMENT Properties:
%	protocol -
%
% BIGODEPLOYMENT Methods:
%	bigoDeployment -
%
%
% Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)

	properties
        protocol table
    end

	methods
        function obj = bigoDeployment(path,varargin)

            if nargin == 0
                path = char.empty;
            end

         	gearType    = 'BIGO';

            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType);

            % support empty initializeation of gearDeployment subclasses
            if isempty(path)
                return
            end

            determineHardwareConfiguration(obj);
            readProtocol(obj);
            readInternalMeasuringDevices(obj);

            obj.timeOfInterestStart	= mean(obj.protocol{obj.protocol{:,'Event'} == 'Experiment Start','Time'},'omitnan');
            obj.timeOfInterestEnd   = mean(obj.protocol{obj.protocol{:,'Event'} == 'Slide Down','StartTime'},'omitnan');

            readAuxillaryMeasuringDevices(obj);
            assignMeasuringDeviceMountingData(obj);
            calibrateMeasuringDevices(obj);
            readAnalyticalSamples(obj);
        end
    end

   	% methods in seperate files
    methods (Access = public)
       	runAnalysis(obj)
        varargout = exportProtocol(obj,varargin)
        tbl = getFlux(obj,variables)
        s = saveobj(obj)
        obj = reloadobj(obj,s)
    end
    methods (Static)
        obj = loadobj(s)
    end

    methods (Access = protected)
        readInternalMeasuringDevices(obj)
        determineHardwareConfiguration(obj)
        readProtocol(obj)
    end
end
