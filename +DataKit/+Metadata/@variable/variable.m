classdef variable < DataKit.enum
    enumeration
        % variable                  (Id,    Abbreviation,   Symbol,      Name,                              Type,               Unit,       UnitRegexp,                     PangaeaId, Description
        undefined                   (0,     '',             '',         '',                                 '',                 '',         '',                             NaN,    '')
        ParticulateOrganicNitrogen  (1,     'PON',          'PON',      'Nitrogen, organic, particulate',	'Concentration',	'mass %',	'mass %',                       26498,	'')
        TotalCarbon                 (2,     'TC',           'TC',       'Carbon, total',                    'Concentration',	'mass %',	'mass %',                       735,	'')
        Sulfur                      (3,     'S',            'S',        'Sulfur',                           'Concentration',	'mass %',	'mass %',                       186962,	'')
        ParticulateOrganicCarbon    (4,     'POC',          'POC',      'Carbon, organic, particulate',     'Concentration',	'mass %',	'mass %',                       18829,	'')
        ParticulateInorganicCarbon  (5,     'PIC',          'PIC',      'Carbon, inorganic, particulate',	'Concentration',	'mass %',	'mass %',                       26499,	'')
        CalciumCarbonate            (6,     'CaCO₃',        'CaCO₃',	'Calcium carbonate',                'Concentration',	'mass %',	'mass %',                       70,     '')
        Porosity                    (7,     'poros.',       'Φ',        'Porosity',                         '',                 'vol %',	'vol %',                        26,     'Fraction of the porevolume relative to the total volume.')
        WaterContent                (8,     'water wm.',	'θ',        'Water content, wet mass',          '',                 'mass %',	'mass %',                       19,     'Relative gravimetric water content of the bulk wet mass')
        Nitrite                     (9,     'NO₂⁻',         'NO₂⁻',     'Nitrite',                          'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      757,	'')
        Nitrate                     (10,	'NO₃⁻',         'NO₃⁻',     'Nitrate',                          'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      756,	'')
        Phosphate                   (11,	'PO₄³⁻',        'PO₄³⁻',	'Phosphate',                        'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      758,	'')
        Silicate                    (12,	'Si(OH)₄',      'Si(OH)₄',	'Silicate',                         'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      755,	'')
        Ammonium                    (13,	'NH₄⁺',         'NH₄⁺',     'Ammonium',                         'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      52,     '')
        Voltage                     (14,	'voltage',      'U',        'Voltage',                          '',                 'V',        'V',                            NaN,   	'')
        Oxygen                      (15,	'O₂',           'O₂',       'Oxygen',                           'Concentration',	'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',      754,	'')
        Temperature                 (16,	'temp.',        't',        'Temperature',                      '',                 '°C',       '(°|deg\s?)C',                  NaN,	'')
        Conductivity                (17,	'cond.',        'cond.',	'Conductivity',                     '',                 'mS cm⁻¹',	'mS(\scm(⁻¹|-1)|/cm)',          NaN,	'')
        Salinity                    (18,	'sal.',         'S',        'Salinity',                         '',                 'PSU',      '(PSU|psu)',                    716,	'')
        Illuminance                 (19,	'illum.',       'Eᵥ',       'Illuminance',                      '',                 'lux',      '(L|l)ux',                      NaN,	'')
        AnalogInput1                (20,	'A1',           'A1',       'Analog Input 1',                   '',                 'counts',	'(C|c)ounts',                   NaN,	'')
        AnalogInput2                (21,	'A2',           'A2',       'Analog Input 2',                   '',                 'counts',	'(C|c)ounts',                   NaN,	'')
        Pressure                    (23,	'press.',       'p',        'Pressure',                         '',                 'dbar',     'd(|eci)b(|ar)',                NaN,	'')
        Turbidity                   (24,	'turb.',        'turb.',	'Turbidity',                        '',                 'NTU',      '(NTU|ntu)',                    NaN,	'')
        Density                     (25,	'dens.',        'ρ',        'Density',                          '',                 'kg m⁻³',	'kg(\sm(⁻³|-3)|(/m|/m³)',       NaN,	'')
        VelocityU                   (26,	'velU',         'u',        'Velocity, u',                      '',                 'm s⁻¹',	'm(\ss(⁻¹|-1)|/s)',             NaN,	'')
        VelocityV                   (27,	'velV',         'v',        'Velocity, v',                      '',                 'm s⁻¹',	'm(\ss(⁻¹|-1)|/s)',             NaN,	'')
        VelocityW                   (28,	'velW',         'w',        'Velocity, w',                      '',                 'm s⁻¹',	'm(\ss(⁻¹|-1)|/s)',             NaN,	'')
        Chloride                    (29,	'Cl⁻',          'Cl⁻',      'Chloride',                         'Concentration',	'mM',       'mmol(\sL(⁻¹|-1)|/L)',          54,     '')
        Bromide                     (30,	'Br⁻',          'Br⁻',      'Bromide',                          'Concentration',	'µM',       'mmol(\sL(⁻¹|-1)|/L)',          161330,	'')
        Sulfate                     (31,	'SO₄²⁻',        'SO₄²⁻',	'Sulfate',                          'Concentration',	'mM',       'mmol(\sL(⁻¹|-1)|/L)',          50,     '')
        Time                        (32,    't',            't',        'Time',                             '',                 's',        's(ec|ek)?(onds|unden)?',      	NaN,    '')
        Depth                       (33,    'z',            'z',        'Depth',                            'Length',         	'm',        'm',                            NaN,    '')
        PotentialTemperature        (34,    'pot. temp.',   'θ',        'Temperature, potential',          	'',                 '°C',      	'(°|deg\s?)C',               	NaN,    '')
        X                           (35,    'x',            'x',        'Euclidean dimension 1, X',       	'Length',       	'm',        'm',                            NaN,    '')
        Y                           (36,    'y',            'y',        'Euclidean dimension 2, Y',        	'Length',       	'm',        'm',                            NaN,    '')
        Z                           (37,    'z',            'z',        'Euclidean dimension 3, Z',        	'Length',       	'm',        'm',                            NaN,    '')
        Longitude                 	(38,    'lon.',         'λ',        'Longitude',                        'Angle',            '°E',       '°',                            NaN,    '')
        Latitude                   	(39,    'lat.',         'φ',        'Latitude',                         'Angle',            '°N',       '°',                            NaN,    '')
        DurationMs                 	(40,    'dur.',         'Δt',       'Duration',                         'Duration',         'ms',       'm(illi)?s(econd)?s?',          NaN,    '')
        DurationS                 	(41,    'dur.',         'Δt',       'Duration',                         'Duration',         's',        's(econd)?s?',                  NaN,    '')
        DurationMin                	(42,    'dur.',         'Δt',       'Duration',                         'Duration',         'min',      'min(ute)?s?',                  NaN,    '')
        DurationH                	(43,    'dur.',         'Δt',       'Duration',                         'Duration',         'h',        'h(our)?s?',                    NaN,    '')
        DurationD                	(44,    'dur.',         'Δt',       'Duration',                         'Duration',         'd',        'd(ay)?s?',                     NaN,    '')
        DurationY                	(45,    'dur.',         'Δt',       'Duration',                         'Duration',         'y',        'y(ear)?s?',                    NaN,    '')
        Boron                       (46,    'B⁻',           'B⁻',       'Boron',                            'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Manganese                   (47,    'Mn',           'Mn',       'Manganese',                     	'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        Calcium                     (48,    'Ca²⁺',         'Ca²⁺',     'Calcium',                          'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Iron                        (49,    'Fe',           'Fe',       'Iron',                             'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        Sodium                      (50,    'Na',           'Na',       'Sodium',                           'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Magnesium                   (51,    'Mg',           'Mg',       'Magnesium',                        'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Strontium                	(52,    'Sr',           'Sr',       'Strontium',                        'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        Silicium                    (53,    'Si',           'Si',       'Silicium',                         'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Barium                      (54,    'Ba',           'Ba',       'Barium',                           'Concentration',    'nM',       'nmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Lithium                     (55,    'Li',           'Li',       'Lithium',                          'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        Potassium                   (56,    'K',            'K',        'Potassium',                        'Concentration',    'mM',       'mmol(\sL(⁻¹|-1)|/L)',          NaN,    '')
        Zinc                        (57,    'Zn',           'Zn',       'Zinc',                             'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        DissolvedInorganicCarbon    (58,    'DIC',          'DIC',      'Carbon, inorganic, dissolved',   	'Concentration',    'µM',       '(µ|u)mol(\sL(⁻¹|-1)|/L)',  	NaN,    '')
        Pitch                       (59,    'pitch',        'pitch',    'Pitch',                            '',                 '°',        '°|((d|D)eg(ree)?s?)',         	NaN,    '')
        Roll                        (60,    'roll',         'roll',     'Roll',                             '',                 '°',        '°|((d|D)eg(ree)?s?)',         	NaN,    '')
        Yaw                         (61,    'yaw',          'yaw',      'Yaw',                              '',                 '°',        '°|((d|D)eg(ree)?s?)',         	NaN,    '')
    end
    properties (SetAccess = 'immutable')
        Id uint16
        Abbreviation char
        Symbol char
        Name char
        Type char
        Unit char
        UnitRegexp char
        PangaeaId uint16
        Description char
    end
    properties (Hidden, SetAccess = 'immutable')
        PangaeaParameterListFilename = '/PANGAEAParameterComplete.tab.tsv'
    end

    methods
        function obj = variable(id, abbreviation, symbol, name, type, unit, unitRegexp, pangaeaId, description,varargin)
            obj.Id = id;
            obj.Abbreviation = abbreviation;
            obj.Symbol = symbol;
            obj.Name = name;
            obj.Type = type;
            obj.Unit = unit;
            obj.UnitRegexp = unitRegexp;
            obj.PangaeaId = pangaeaId;
            obj.Description = description;
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
