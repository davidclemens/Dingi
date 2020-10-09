function obj = readInternalSensors(obj)

    import GearKit.*
    
    controlUnits            = {'CHMB1','CHMB2'};
    controlUnitsPretty      = {'Ch1','Ch2'};
    controlUnitsOutput      = {'Control Unit 1','Control Unit 2'};
    for cu = 1:numel(controlUnits)
        newSensors                      = [sensor('BigoVoltage',[obj.dataFolderInfo.dataFolder,'/',controlUnits{cu},'/SPL_VLTG.TXT']);...
                                           sensor('BigoOptode',[obj.dataFolderInfo.dataFolder,'/',controlUnits{cu},'/OPTODATA.TXT']);...
                                           sensor('BigoConductivity',[obj.dataFolderInfo.dataFolder,'/',controlUnits{cu},'/CONDUCT.TXT'])];
        [newSensors.mountingLocation]	= deal(controlUnitsOutput{cu});
       	[newSensors.group]              = deal('internal');
        
        obj.sensors                     = [obj.sensors; newSensors];
    end
end