classdef validFlag
    enumeration
        % quality flag                   id     description
        undefined                       (0,     '')
        OutOfCalibrationRange           (1,     'Value out of calibration range')
        BelowDetectionLimit             (2,     'Value below the detection limit')
        MarkedRejected                  (3,     'Value was manually rejected')
    end
    properties
        Id uint8
        Description char
    end
    properties (Dependent)
        Bitmask uint64
    end
    methods
        function obj = validFlag(id,description,varargin)
            obj.Id              = id;
            obj.Description     = description;
        end
    end
    
    methods (Static)
        tbl = listAllValidFlagInfo()
    end
    
    % get methods
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