classdef eddyFluxAnalysisDatasetFlag < DataKit.enum
    enumeration
        %                                                Id     Threshold   Abbreviation    Description
        undefined                                       (0,     NaN,        '',             '')
        MissingDataThresholdExceeded                    (1,     0.03,       'miss. data',  	'Too many values are flagged for missing data.')
        AbsoluteLimitsThresholdExceeded                 (2,     0.03,       'abs. lim.',  	'Too many values are flagged for exceeding absolute limits thresholds.')
        ObstructedCurrentDirectionThresholdExceeded    	(3,     0.05,       'curr. dir.',  	'Too many values are flagged for exceeding the obstructed current direction threshold.')
        LowSignalToNoiseRatio                           (4,     0.03,       'low SNR',  	'Too many values are flagged for low signal to noise ratio.')
        LowBeamCorrelation                              (5,     0.03,       'low BC',       'Too many values are flagged for low beam correlation.')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Threshold double
        Abbreviation char
        Description char
    end
    methods
        function obj = eddyFluxAnalysisDatasetFlag(id,threshold,abbreviation,description,varargin)
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