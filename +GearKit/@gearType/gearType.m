classdef gearType < DataKit.enum
    enumeration
        %            Name                           Abbreviation    File Extension
        undefined   ('',                            '',             '')
        BIGO        ('Biogeochemical Observatory',  'BIGO',         '.bigo')
        EC          ('Eddy Correlation Lander',     'ECL',          '.ec')
    end
    properties (SetAccess = 'immutable')
        Name char
        Abbreviation char
        FileExtension char
    end
    methods
        function obj = gearType(name,abbreviation,fileExtension,varargin)
            obj.Name            = name;
            obj.Abbreviation    = abbreviation;
            obj.FileExtension	= fileExtension;
        end
    end
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end