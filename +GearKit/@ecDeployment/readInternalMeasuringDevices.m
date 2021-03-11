function readInternalMeasuringDevices(obj)
% READINTERNALSENSORS
    
    import DebuggerKit.Debugger.printDebugMessage
    
    printDebugMessage('Info','Reading internal measuring device(s)...')
    
    dirList         = dir([obj.dataFolderInfo.dataFolder,'/*.vec']);
    vecFileNames    = strcat({dirList.folder},{'/'},{dirList.name});
    
    for ff = 1:numel(vecFileNames)
        obj.data    = obj.data.addPool;
        obj.data    = obj.data.importData('NortekVector',vecFileNames{ff});
    end
    
    printDebugMessage('Info','Reading internal measuring device(s)... done')
end