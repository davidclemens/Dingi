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
    
    methods
        [C,ia,ic] = unique(obj,varargin)
        value = toProperty(obj,propertyname)
    end
    
    % Core methods
    methods (Static)
        L = core_listMembers(classname)
        T = core_listMembersInfo(classname)
        obj = core_fromProperty(classname,propertyname,value)
        [tf,info] = core_validate(classname,propertyname,value)
    end
    
    % Abstract
    methods (Static, Abstract)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end