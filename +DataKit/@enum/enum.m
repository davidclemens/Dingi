classdef enum
    
    methods
        function obj = enum()
            
        end
    end
    methods
        varargout = sort(obj,varargin)
    end
    methods (Static)
        obj = cell2enum(C,classname)
    end
    
    % Core methods
    methods (Static)
        L = core_listMembers(classname)
        obj = core_fromProperty(classname,propertyname,value)
    end
    
    % Abstract
    methods (Static, Abstract)
        L = listMembers()
        obj = fromProperty(propertyname,value)
    end
end