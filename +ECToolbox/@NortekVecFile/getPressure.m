function pressure = getPressure(obj)
    structureId     = 16;
    pressureRaw   	= [obj.getDataArray(structureId,4,'uint8'),...
                       obj.getDataArray(structureId,6:7,'uint16')];
    pressure       	= 1e-3.*sum(pressureRaw.*[2^16,1],2);
end