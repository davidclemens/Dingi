function readInternalMeasuringDevices(obj)
    
    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','Reading internal measuring device(s)...',char(obj.gearType))
    
    controlUnits            = {'CHMB1','CHMB2'};
    controlUnitsPretty      = {'Ch1','Ch2'};
    controlUnitsOutput      = {'Control Unit 1','Control Unit 2'};
    measuringUnitType     	= {'BigoVoltage','BigoOptode','BigoConductivityCell'};
    measuringUnitPath     	= {'/SPL_VLTG.TXT','/OPTODATA.TXT','/CONDUCT.TXT'};
    for cu = 1:numel(controlUnits)
        for mu = 1:numel(measuringUnitType)
            obj.data.addPool;
            obj.data.importData(measuringUnitType{mu},[obj.dataFolderInfo.dataFolder,'/',controlUnits{cu},measuringUnitPath{mu}]);
        end
    end
    
    printDebugMessage('Info','Reading internal measuring device(s)... done',char(obj.gearType))
end