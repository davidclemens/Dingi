classdef debugLevel < DataKit.enum
    enumeration
        % debugLevel	 Id     Name            Abbreviation    Color
        FatalError      (1,     'Fatal Error', 	'FE',         	'[1.000,0.000,0.000]')
        Error           (2,     'Error',        'E',            '[1.000,0.000,0.000]')
        Warning         (3,     'Warning',      'W',            '[1.000,0.400,0.000]')
        Info            (4,     'Info',         'I',            '[0.094,0.550,0.094]')
        Verbose         (5,     'Verbose',      'V',            'black')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Name char
        Abbreviation char
        Color char
    end
    methods
        function obj = debugLevel(id,name,abbreviation,color,varargin)
            obj.Id              = id;
            obj.Name            = name;
            obj.Abbreviation    = abbreviation;
            obj.Color           = color;
        end
    end
    
    % Overloaded methods
    methods
        tf = ge(objA,objB)
    end
    
    % Static methods
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end