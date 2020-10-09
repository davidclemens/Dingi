function batteryVoltage = getBatteryVoltage(obj)
    structureId         = 17;
    batteryVoltageRaw 	= obj.getDataArray(structureId,10:11,'uint16');
	% scale battery voltage
    batteryVoltage   	= 0.1.*batteryVoltageRaw;
end