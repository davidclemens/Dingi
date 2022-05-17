function determineHardwareConfiguration(obj)
% DETERMINEHARDWARECONFIGURATION
    
    import GearKit.hardwareConfiguration
    
    obj.HardwareConfiguration   = hardwareConfiguration(obj);
    
end