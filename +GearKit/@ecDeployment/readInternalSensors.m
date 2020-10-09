function obj = readInternalSensors(obj)
% READINTERNALSENSORS

    import GearKit.sensor
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal sensor(s)... \n');
    end
    
    dirList         = dir([obj.dataFolderInfo.dataFolder,'/*.vec']);
    vecFileNames    = strcat({dirList.folder},{'/'},{dirList.name});
    
    for ff = 1:numel(vecFileNames)
        newSensor       = sensor('NortekVector',vecFileNames{ff});
        
        obj.sensors  	= [obj.sensors; newSensor];
    end
    
    [obj.sensors.group]	= deal('internal');
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal sensor(s)... done\n');
	end
end