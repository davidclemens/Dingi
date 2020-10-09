function soundSpeed = getSoundSpeed(obj)
    structureId 	= 17;
    soundSpeedRaw 	= obj.getDataArray(structureId,12:13,'uint16');
	% scale soundspeed
    soundSpeed   	= 0.1.*soundSpeedRaw; % m/s
end