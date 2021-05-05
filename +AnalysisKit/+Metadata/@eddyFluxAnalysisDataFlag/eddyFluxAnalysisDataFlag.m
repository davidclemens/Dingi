classdef eddyFluxAnalysisDataFlag < DataKit.enum
    enumeration
        %                                            Id     Threshold   Abbreviation            Description
        undefined                                   (0,     NaN,        '',                     '')
        AbsoluteHorizontalVelocityLimitExceeded   	(1,     2,          'horz. vel. lim.',    	'Absolute horizontal velocity limits are exceeded.')
        AbsoluteVerticalVelocityLimitExceeded   	(2,     0.75,       'vert. vel. lim.',     	'Absolute vertical velocity limits are exceeded.')
        ObstructedCurrentDirection                  (3,     NaN,        'curr. dir.',         	'The current originates from a direction with an obstacle in the way.')
        IsInterpolated                              (4,     NaN,        'interp.',              'The value has been interpolated.')
        LowSignalToNoiseRatio                      	(5,     5,          'low SNR',              'The signal to noise ratio is too low.')
        LowBeamCorrelation                          (6,     70,         'low BC',               'The beam correlation is too low.')
        LowAmplitudeResolution                   	(7,     0.7,        'low amp. res.',       	'The amplitude resolution is too low.')
        IsSetToNaN                                	(8,     NaN,        'set to NaN',       	'The value has been set to NaN.')
        
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Threshold double
        Abbreviation char
        Description char
    end
    methods
        function obj = eddyFluxAnalysisDataFlag(id,threshold,abbreviation,description,varargin)
            obj.Id              = id;
            obj.Threshold       = threshold;
            obj.Abbreviation    = abbreviation;
            obj.Description     = description;
        end
    end
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
end