classdef worldDomain
    enumeration
        undefined               ('')
        BenthicWaterColumn      ('BWC')
        PelagicWaterColumn      ('PWC')
        Sediment                ('Sed')
    end
    properties (SetAccess = 'immutable')
        Abbreviation char
    end
    methods
        function obj = worldDomain(abbreviation,varargin)
            obj.Abbreviation = abbreviation;
        end
    end
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
    end
end