classdef validInfoVariableType < DataKit.enum
    enumeration
        % validInfoVariableType	Id      Name
        undefined               (0,     '<undefined>')
        Dependent               (1,     'dependent')
        Independent             (2,     'independent')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Name char        
    end
    
    methods
        function obj = validInfoVariableType(id,name,varargin)
            obj.Id              = id;
            obj.Name            = name;
        end
    end
    
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end