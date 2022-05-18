classdef bigoFluxAnalysisDataFlag < DataKit.enum
    enumeration
        %                                            Id     Threshold   % Threshold unit    Abbreviation            Description
        undefined                                   (0,     NaN,        '',                 '',                     '')
        IsManuallyExcludedFromFit                   (1,     NaN,        '',                 'man. excl.',           'The value has been manually excluded.')
        IsNaN                                       (2,     NaN,        '',                 'is NaN',               'The value is NaN.')
        IsSample                                  	(3,     NaN,        '',                 'is sample',          	'The value is a sample and not a padding NaN.')
        IsNotInFitInterval                         	(4,     NaN,        '',                 'is not in fit int.',  	'The value is not within the fitting interval.')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Threshold double
        ThresholdUnit char
        Abbreviation char
        Description char
    end
    methods
        function obj = bigoFluxAnalysisDataFlag(id,threshold,thresholdUnit,abbreviation,description,varargin)
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