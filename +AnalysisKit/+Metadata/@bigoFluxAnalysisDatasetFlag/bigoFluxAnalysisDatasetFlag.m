classdef bigoFluxAnalysisDatasetFlag < DataKit.enum
    enumeration
        %                                                Id     Threshold   Abbreviation            Description
        undefined                                       (0,     NaN,        '',                     '')
        MissingDataThresholdExceeded                    (1,     0.50,       'miss. data',           'Too many values are flagged for missing data.')
        InsufficientFittingData                         (2,     2,          'insuf. fit data',      'Insufficient data for fitting available.')
        BadGoodnessOfFit                                (3,     NaN,        'bad GOF',              'The goodness of fit is not satisfactory.')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Threshold double
        Abbreviation char
        Description char
    end
    methods
        function obj = bigoFluxAnalysisDatasetFlag(id,threshold,abbreviation,description,varargin)
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
