function list = listAllMeasuringDevice()

    [~,list] = enumeration('GearKit.measuringDevice');
end