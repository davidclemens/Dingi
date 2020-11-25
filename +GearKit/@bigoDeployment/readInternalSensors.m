function obj = readInternalSensors(obj)

    import GearKit.*
    
    controlUnits            = {'CHMB1','CHMB2'};
    controlUnitsPretty      = {'Ch1','Ch2'};
    controlUnitsOutput      = {'Control Unit 1','Control Unit 2'};
    measuringUnitType     	= {'BigoVoltage','BigoOptode','BigoConductivityCell'};
    measuringUnitPath     	= {'/SPL_VLTG.TXT','/OPTODATA.TXT','/CONDUCT.TXT'};
    for cu = 1:numel(controlUnits)
        for mu = 1:numel(measuringUnitType)
            obj.data    = obj.data.addPool;
            obj.data    = obj.data.importData(measuringUnitType{mu},[obj.dataFolderInfo.dataFolder,'/',controlUnits{cu},measuringUnitPath{mu}]);
        end
        
%         [newSensors.mountingLocation]	= deal(controlUnitsOutput{cu});
%        	[newSensors.group]              = deal('internal');
%         
%         obj.sensors                     = [obj.sensors; newSensors];
    end
end