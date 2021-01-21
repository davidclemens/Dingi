function readAuxillaryMeasuringDevices(obj)
% READAUXILLARYSENSORS

    import GearKit.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading auxillary measuring device(s)... \n');
	end
    
    dirList           	= dir([obj.dataFolderInfo.dataFolder,'/AuxSensor_*']);
	tmpMetadata       	= regexp({dirList.name},'AuxSensor_(\w+)_(\w+)','tokens');
    tmpMetadata        	= cat(1,tmpMetadata{:});
    tmpMetadata        	= cat(1,tmpMetadata{:});
    measuringUnitTypes	= tmpMetadata(:,1);
    measuringUnitExt   	= tmpMetadata(:,2);
	nMeasuringUnitTypes	= size(dirList,1);
    for mut = 1:nMeasuringUnitTypes
        path                = [dirList(mut).folder,'/',dirList(mut).name];
        measuringUnitList   = dir([path,'/*.',measuringUnitExt{mut}]);
        nMeasuringUnits     = numel(measuringUnitList);
        for mu = 1:nMeasuringUnits
            obj.data    = obj.data.addPool;
          	obj.data    = obj.data.importData(measuringUnitTypes{mut},[path,'/',measuringUnitList(mu).name]);
        end
    end
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading auxillary measuring device(s)... done\n');
	end
end