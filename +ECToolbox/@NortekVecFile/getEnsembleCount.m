function ensembleCount = getEnsembleCount(obj)
    structureId     = 16;
    ensembleCount  	= obj.getDataArray(structureId,3,'uint8');
end