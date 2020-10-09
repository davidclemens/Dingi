function analogInput1 = getAnalogInput1(obj)
    structureId     = 16;
    analogInput1   	= obj.getDataArray(structureId,8:9,'uint16'); % in counts
end