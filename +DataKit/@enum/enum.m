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
        obj = core_fromProperty(classname,propertyname,values)
        [tf,info] = core_validate(classname,propertyname,values)
    end
    
    % Helper methods
    methods (Static)
        className = validateClassName(className)
        propertyName = validatePropertyName(className,propertyName)
        propertyValues = validatePropertyValues(className,propertyName,propertyValue)
        [tf,ind] = isValidPropertyValue(className,propertyName,value)
        validPropertyValues = listValidPropertyValues(className,propertyName)
    end
    
    % Abstract
    methods (Static, Abstract)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end