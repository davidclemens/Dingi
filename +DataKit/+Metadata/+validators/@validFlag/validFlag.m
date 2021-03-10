classdef validFlag < DataKit.enum
    enumeration
        % validFlag                     Id      Name                            Description
        undefined                       (0,     '<undefined>',                  '')
        OutOfCalibrationRange           (1,     'out of calibration range', 	'Value out of calibration range')
        BelowDetectionLimit             (2,    	'below detection limit',        'Value below the detection limit')
        MarkedRejected                  (3,     'marked rejected',              'Value was manually rejected')
        ExcludeFromFit                  (4,     'exluded from fit',             'Value should be excluded from fitting')
    end
    properties (SetAccess = 'immutable')
        Id uint8
        Name char
        Description char
    end
    properties (Dependent, SetAccess = 'immutable')
        Bitmask uint64
    end
    methods
        function obj = validFlag(id,name,description,varargin)
            obj.Id              = id;
            obj.Name            = name;
            obj.Description     = description;
        end
    end
    
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
        [tf,info] = validate(propertyname,value)
    end
    
    % Get methods
    methods
        function Bitmask = get.Bitmask(obj)
            if obj.Id == 0
                Bitmask = 0;
            else
                Bitmask = bitset(0,obj.Id,1);
            end
        end
    end
end