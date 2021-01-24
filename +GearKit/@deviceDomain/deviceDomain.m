classdef deviceDomain < DataKit.enum
    enumeration
        undefined           ('')
        ControlUnit1        ('CU1')
        ControlUnit2        ('CU2')
        Chamber1            ('Ch1')
        Chamber2            ('Ch2')
        BottomWater         ('BW')
        Chamber1Water       ('Ch1W')
        Chamber2Water       ('Ch2W')
    end
    properties (SetAccess = 'immutable')
        Abbreviation char
    end
    methods
        function obj = deviceDomain(abbreviation,varargin)
            obj.Abbreviation = abbreviation;
        end
    end
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
    end
end