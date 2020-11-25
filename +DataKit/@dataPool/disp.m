function disp(obj)
    
    info = obj.info;
    
    info.MeasuringDeviceType                = categorical(cellstr([info.MeasuringDevice.Type])');
    info.MeasuringDeviceSerialNumber     	= categorical({info.MeasuringDevice.SerialNumber}');
    info.MeasuringDeviceMountingLocation 	= categorical({info.MeasuringDevice.MountingLocation}');
    info.MeasuringDeviceWorldDomain     	= categorical(cellstr([info.MeasuringDevice.WorldDomain])');
    
    info.Variable           = categorical(cellstr(info{:,'Variable'}));   
    info.MeasuringDevice    = [];
    
    disp(info)
end