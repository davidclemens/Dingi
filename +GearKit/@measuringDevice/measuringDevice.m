classdef measuringDevice
    
    properties
        Type(1,1) GearKit.validators.validMeasuringDevice = GearKit.validators.validMeasuringDevice.none
        SerialNumber(1,:) char = ''
        MountingLocation(1,:) char = ''
        WorldDomain(1,1) GearKit.validators.validWorldDomain = GearKit.validators.validWorldDomain.none
    end
    
    methods
        function obj = measuringDevice()
            
        end
    end
end