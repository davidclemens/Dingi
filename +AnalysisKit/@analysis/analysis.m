classdef analysis < handle
    properties (Abstract)
        Name char
        Type char
        Parent
    end
    methods
        function obj = analysis()
            
        end
    end
    
    % Methods in other files
    methods
        varargout = plot(obj,varargin)
    end
end