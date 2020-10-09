function amplitude = getAmplitude(obj)
    structureId     = 16;
    amplitudeRaw   	= [obj.getDataArray(structureId,16,'uint8'),...
                       obj.getDataArray(structureId,17,'uint8'),...
                       obj.getDataArray(structureId,18,'uint8')];
    amplitude      	= amplitudeRaw;
end