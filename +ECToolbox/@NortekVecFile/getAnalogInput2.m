function analogInput2 = getAnalogInput2(obj)
    structureId     = 16;
    analogInput2   	= obj.getDataArray(structureId,[2,5],'uint16'); % in counts
end