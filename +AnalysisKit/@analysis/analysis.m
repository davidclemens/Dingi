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
        setUpdateStackToUpdated(obj,stackDepth)
        setUpdateStackToUpdating(obj,stackDepth)
        setUpdateStackToUpdateRequired(obj,stackDepth)
    end
    methods (Abstract)
        checkUpdateStack(obj,stackDepth)
    end
end