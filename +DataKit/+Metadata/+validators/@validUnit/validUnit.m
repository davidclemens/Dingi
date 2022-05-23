classdef validUnit < DataKit.enum
    enumeration
        % unit                      (Id,    Abbreviation,   Symbol,      Name,                              Category,           IsSI,           Constant,       Alias,                      
        undefined                   (0,     '',             '',         '',                                 '',                 false,      	[],             {}                          )
        
        % SI prefixes
        yotta                       (1,     'Y',            'Y',        'yotta',                            'Prefix',           false,          1e24,           {}                          )
        zetta                       (2,     'Z',            'Z',        'zetta',                            'Prefix',           false,          1e21,           {}                          )
        exa                         (3,     'E',            'E',        'exa',                              'Prefix',           false,          1e18,           {}                          )
        peta                        (4,     'P',            'P',        'peta',                             'Prefix',           false,          1e15,           {}                          )
        tera                        (5,     'T',            'T',        'tera',                             'Prefix',           false,          1e12,           {}                          )
        giga                        (6,     'G',            'G',        'giga',                             'Prefix',           false,          1e9,            {}                          )
        mega                        (7,     'M',            'M',        'mega',                             'Prefix',           false,          1e6,            {}                          )
        kilo                        (8,     'k',            'k',        'kilo',                             'Prefix',           false,          1e3,            {}                          )
        hecto                       (9,     'h',            'h',        'hecto',                            'Prefix',           false,          1e2,            {}                          )
        deka                        (10,    'da',           'da',       'deka',                             'Prefix',           false,          1e1,            {}                          )
        deci                        (11,    'd',            'd',        'deci',                             'Prefix',           false,          1e-1,           {}                          )
        centi                       (12,    'c',            'c',        'centi',                            'Prefix',           false,          1e-2,           {}                          )
        milli                       (13,    'm',            'm',        'milli',                            'Prefix',           false,          1e-3,           {}                          )
        micro                       (14,    'µ',            'µ',        'micro',                            'Prefix',           false,          1e-6,           {}                          )
        nano                        (15,    'n',            'n',        'nano',                             'Prefix',           false,          1e-9,           {}                          )
        pico                        (16,    'p',            'p',        'pico',                             'Prefix',           false,          1e-12,          {}                          )
        femto                       (17,    'f',            'f',        'femto',                            'Prefix',           false,          1e-15,          {}                          )
        atto                        (18,    'a',            'a',        'atto',                             'Prefix',           false,          1e-18,          {}                          )
        zepto                       (19,    'z',            'z',        'zepto',                            'Prefix',           false,          1e-21,          {}                          )
        yocto                       (20,    'y',            'y',        'yocto',                            'Prefix',           false,          1e-24,          {}                          )
        
        % SI base units
        metre                       (21,    'm',            'm',        'metre',                            'Length',                       true,           [],             {'metres','meter','meters'})
        kilogram                    (22,    'kg',           'km',       'kilogram',                         'Mass',                         true,           [],             {'kilograms'})
        second                      (23,    's',            's',        'second',                           'Time',                         true,           [],             {'seconds'})
        ampere                      (24,    'A',            'A',        'ampere',                           'Electric Current',             true,           [],             {'amperes'})
        kelvin                      (25,    'A',            'A',        'ampere',                           'Thermodynamic Temperature',  	true,           [],             {})
        mole                        (26,    'mol',          'mol',      'mole',                             'Amount of Substance',          true,           [],             {'moles'})
        candela                     (27,    'cd',           'cd',       'candela',                          'Luminous Intensity',           true,           [],             {})
    end
    properties (SetAccess = 'immutable')
        Id uint16
        Abbreviation char
        Symbol char
        Name char
        Category char
        IsSI logical
        Constant double
        Alias cell
    end
    properties (Hidden, SetAccess = 'immutable')
        PangaeaParameterListFilename = '/PANGAEAParameterComplete.tab.tsv'
    end

    methods
        function obj = validUnit(id, abbreviation, symbol, name, category, isSI, constant, alias)
            obj.Id = id;
            obj.Abbreviation = abbreviation;
            obj.Symbol = symbol;
            obj.Name = name;
            obj.Category = category;
            obj.IsSI = isSI;
            obj.Constant = constant;
            obj.Alias = alias;
        end
    end

    % overloaded methods
    methods (Access = public)
        disp(obj)
    end

    % Inherited abstract methods from superclass
    methods (Static)
        tbl = listMembersInfo()
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end
