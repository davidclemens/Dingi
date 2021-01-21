classdef bigoDeployment < GearKit.gearDeployment
% BIGODEPLOYMENT Represents a Geomar BIGO deployment
%	The BIGODEPLOYMENT class reads all data related to a single Geomar BIGO
%	deployment. The resulting object has plot, analysis and export methods.
%
% BIGODEPLOYMENT Properties:
%	chamber -
%	protocol -
%
% BIGODEPLOYMENT Methods:
%	bigoDeployment -
%
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

	properties
        chamber struct
        protocol table
    end

	methods
        function obj = bigoDeployment(path,varargin)

            if nargin == 0
                path = char.empty;
            end

            % parse Name-Value pairs
            optionName          = {'DebugLevel'}; % valid options (Name)
            optionDefaultValue  = {'Info'}; % default value (Value)
            [debugLevel]     	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

         	gearType    = 'BIGO';

            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType,...
                        'DebugLevel',       debugLevel);

            % support empty initializeation of gearDeployment subclasses
            if isempty(path)
                return
            end

            determineChamberMetadata(obj);
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
        tbl = getFlux(obj,parameter)
    end

    methods (Access = protected)
        readInternalMeasuringDevices(obj)
        determineChamberMetadata(obj)
        readProtocol(obj)
    end
end
