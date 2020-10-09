function compass = getCompass(obj)
    structureId	= 17;
    compassRaw	= [obj.getDataArray(structureId,14:15,'int16'),...
                   obj.getDataArray(structureId,16:17,'int16'),...
                   obj.getDataArray(structureId,18:19,'int16')];
	% scale compass
    compass     = 0.1.*compassRaw;
end