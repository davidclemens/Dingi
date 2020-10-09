function obj = readAuxillarySensors(obj)
% READAUXILLARYSENSORS

    import GearKit.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading auxillary sensor(s)... \n');
	end
    
    dirList         = dir([obj.dataFolderInfo.dataFolder,'/AuxSensor_*']);
	tmpMetadata     = regexp({dirList.name},'AuxSensor_(\w+)_(\w+)','tokens');
    tmpMetadata     = cat(1,tmpMetadata{:});
    tmpMetadata     = cat(1,tmpMetadata{:});
    sensorTypes     = tmpMetadata(:,1);
    sensorExt       = tmpMetadata(:,2);
	nSensorTypes    = size(dirList,1);
    for sensType = 1:nSensorTypes
        path        = [dirList(sensType).folder,'/',dirList(sensType).name];
        sensorList  = dir([path,'/*.',sensorExt{sensType}]);
        nSensors    = numel(sensorList);
        for sens = 1:nSensors
            switch sensorTypes{sensType}
                case 'HoboLightLogger'
                    newSensor     = sensor('HoboLightLogger',[path,'/',sensorList(sens).name]);
                case 'SeabirdCTD'
                    newSensor     = sensor('SeabirdCTD',[path,'/',sensorList(sens).name]);
                case 'O2Logger'
                    newSensor     = sensor('O2Logger',[path,'/',sensorList(sens).name]);
                otherwise
                    warning('readAuxillarySensors:sensorNotImplemented',...
                            'Auxillary sensor type ''%s'' is not implemented yet. It is ignored',sensorTypes{sensType})
                  	continue
            end
            newSensor.group     = 'auxillary';
            
            obj.sensors         = [obj.sensors; newSensor];
        end
    end
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading auxillary sensor(s)... done\n');
	end
end