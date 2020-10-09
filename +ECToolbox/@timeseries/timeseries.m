classdef timeseries < timeseries
    methods
        function obj = timeseries(varargin)
            
            % call superclass constructor
            obj	= obj@timeseries(varargin{:});
        end
        
        tsDespiked	= despike(obj,varargin)
        tsDerived   = derive(obj);
    end
end