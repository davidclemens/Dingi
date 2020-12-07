classdef measuringDevice
    
    properties
        Type(1,1) GearKit.measuringDeviceType = GearKit.measuringDeviceType.undefined
        SerialNumber(1,:) char = ''
        MountingLocation(1,:) char = ''
        WorldDomain(1,1) GearKit.worldDomain = GearKit.worldDomain.undefined
    end
    
    methods
        function obj = measuringDevice()
            
        end
    end
    
    % overloaded methods
    methods
        bool = eq(a,b)
        [C,ia,ic] = unique(A,varargin)
    end
    methods (Static)
        list = listAllMeasuringDevice()
    end
end