classdef eddyFluxAnalysisDataFlag < DataKit.enum
    enumeration
        %                                            Id     Threshold   % Threshold unit    Abbreviation            Description
        undefined                                   (0,     NaN,        '',                 '',                     '')
        AbsoluteHorizontalVelocityLimitExceeded   	(1,     2,          'm/s',              'horz. vel. lim.',    	'Absolute horizontal velocity limits are exceeded.')
        AbsoluteVerticalVelocityLimitExceeded   	(2,     0.75,       'm/s',              'vert. vel. lim.',     	'Absolute vertical velocity limits are exceeded.')
        ObstructedCurrentDirection                  (3,     NaN,        '',                 'curr. dir.',         	'The current originates from a direction with an obstacle in the way.')
        IsInterpolated                              (4,     NaN,        '',                 'interp.',              'The value has been interpolated.')
        LowSignalToNoiseRatio                      	(5,     5,          '',                 'low SNR',              'The signal to noise ratio is too low.')
        LowBeamCorrelation                          (6,     70,         '%',                'low BC',               'The beam correlation is too low.')
        LowAmplitudeResolution                   	(7,     0.7,        '',                 'low amp. res.',       	'The amplitude resolution is too low.')
        IsSetToNaN                                	(8,     NaN,        '',                 'set to NaN',       	'The value has been set to NaN.')
        Spike                                       (9,     NaN,        '',                 'spike',                'The value is identified as a spike.')
        LowHorizontalVelocity                       (10,    0.01,       'm/s',              'low horz. vel.',       'Absolute horizontal velocity is low.')
        HighCurrentRotationRate                     (11,    8,          'rpm',              'high curr. rot. rate', 'The horizontal current rotation rate is high.')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Threshold double
        ThresholdUnit char
        Abbreviation char
        Description char
    end
    methods
        function obj = eddyFluxAnalysisDataFlag(id,threshold,thresholdUnit,abbreviation,description,varargin)
            obj.Id              = id;
            obj.Threshold       = threshold;
            obj.ThresholdUnit   = thresholdUnit;
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