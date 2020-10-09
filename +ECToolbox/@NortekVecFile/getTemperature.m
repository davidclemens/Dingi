function temperature = getTemperature(obj)
    structureId   	= 17;
    temperatureRaw 	= obj.getDataArray(structureId,20:21,'int16');
	% scale temperature
    temperature   	= 0.01.*temperatureRaw;
end