function obj = assignSensorMountingData(obj)
% ASSIGNSENSORMOUNTINGDATA

    import DataKit.importTableFile
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: assigning %s sensor mounting locations... \n',obj.gearType);
	end
    
    sensorsDataFile  = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_sensors.xlsx'];
    try
        sensorsData     = importTableFile(sensorsDataFile);
        sensorsData    	= sensorsData(sensorsData{:,'Cruise'} == obj.cruise & ...
                                      sensorsData{:,'Gear'} == obj.gear,:);
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                warning('no sensor metadata file found for %s %s',char(obj.cruise),char(obj.gear))
            otherwise
                rethrow(ME);
        end
    end
    
    for sens = 1:numel(obj.sensors)
        maskSensorData1 = sensorsData{:,'Id'} == obj.sensors(sens).id & ...
                          sensorsData{:,'SerialNumber'} == obj.sensors(sens).serialNumber & ...
                          ~isundefined(sensorsData{:,'SerialNumber'});
        maskSensorData2 = sensorsData{:,'Id'} == obj.sensors(sens).id & ...
                          categorical(sensorsData{:,'MountingLocation'}) == obj.sensors(sens).mountingLocation & ...
                          ~isundefined(categorical(sensorsData{:,'MountingLocation'}));
        if sum(maskSensorData1) == 1
            obj.sensors(sens).mountingLocation  = char(sensorsData{maskSensorData1,'MountingLocation'});
            obj.sensors(sens).mountingDomain    = char(sensorsData{maskSensorData1,'MountingDomain'});
        elseif sum(maskSensorData2) == 1
            obj.sensors(sens).mountingDomain    = char(sensorsData{maskSensorData2,'MountingDomain'});
        else
            warning('GearKit:gearDeployment:assignSensorMountingLocations:noMountingLocationFound',...
                'There is no mounting data defined in\n\t%s\nfor\n\t%s\n',sensorsDataFile,strjoin({obj.sensors(sens).id,obj.sensors(sens).serialNumber},' '))
        end
    end
    
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: assigning %s sensor mounting locations... done\n',obj.gearType);
	end
end