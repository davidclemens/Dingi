classdef EddyFlux
    properties
        velocityTimeseries
        transportPropertyTimeseries
        velocityTimeseriesDespiked
        transportPropertyTimeseriesDespiked
    end
    methods
        function obj = EddyFlux(velocityTimeseries,transportPropertyTimeseries,varargin)
            
%            	optionName          = {}; % valid options (Name)
%             optionDefaultValue  = {}; % default value (Value)
%             [obj.velocityTimeseries,...
%              obj.transportPropertyTimeseries]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            obj.velocityTimeseries        	= velocityTimeseries;
            obj.transportPropertyTimeseries = transportPropertyTimeseries;
            
            obj.velocityTimeseriesDespiked          = despike(obj.velocityTimeseries);
            obj.transportPropertyTimeseriesDespiked = despike(obj.transportPropertyTimeseries);
        end
    end
end