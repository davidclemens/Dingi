function readInternalMeasuringDevices(obj)
% READINTERNALSENSORS
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal measuring device(s)... \n');
	end
    
    dirList         = dir([obj.dataFolderInfo.dataFolder,'/*.vec']);
    vecFileNames    = strcat({dirList.folder},{'/'},{dirList.name});
    
    for ff = 1:numel(vecFileNames)
        obj.data    = obj.data.addPool;
        obj.data    = obj.data.importData('NortekVector',vecFileNames{ff});
    end
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal measuring device(s)... done\n');
	end
end