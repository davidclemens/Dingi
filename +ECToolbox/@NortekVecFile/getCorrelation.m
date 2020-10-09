function correlation = getCorrelation(obj)
    structureId     = 16;
    correlationRaw 	= [obj.getDataArray(structureId,19,'uint8'),...
                       obj.getDataArray(structureId,20,'uint8'),...
                       obj.getDataArray(structureId,21,'uint8')];
    correlation  	= correlationRaw;
end