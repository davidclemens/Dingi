classdef worldDomain
    enumeration
        undefined               ('')
        BenthicWaterColumn      ('BWC')
        PelagicWaterColumn      ('PWC')
        Sediment                ('Sed')
    end
    properties
        Abbreviation char
    end
    methods
        function obj = worldDomain(abbreviation,varargin)
            obj.Abbreviation = abbreviation;
        end
    end
end