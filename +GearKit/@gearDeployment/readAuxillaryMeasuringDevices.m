function readAuxillaryMeasuringDevices(obj)
% READAUXILLARYSENSORS

    import GearKit.*
    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','Reading auxillary measuring device(s)...')
    
    dirList           	= dir([obj.dataFolderInfo.dataFolder,'/AuxSensor_*']);
    if isempty(dirList)
        % Return if no auxillary sensors exist
        return
    end
	tmpMetadata       	= regexp({dirList.name},'^AuxSensor_(\w+)_(\w+)','tokens');
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
          	obj.data.importData(measuringUnitTypes{mut},[path,'/',measuringUnitList(mu).name]);
        end
    end
    
    printDebugMessage('Info','Reading auxillary measuring device(s)... done')
end