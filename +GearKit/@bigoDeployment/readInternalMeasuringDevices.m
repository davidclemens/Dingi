function obj = readInternalMeasuringDevices(obj)
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal measuring device(s)... \n');
    end
    
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
    end
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading internal measuring device(s)... done\n');
	end
end