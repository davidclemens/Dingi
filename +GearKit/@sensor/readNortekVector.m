function obj = readNortekVector(obj)

    import ECToolbox.*

  	vec         = NortekVecFile(obj.dataPath,...
                    'DebugLevel',       char(obj.debugger.debugLevel));
    
    % write to sensor object
	obj.type                    = 'ADV';
    obj.serialNumber            = vec.HardwareConfiguration.serialNumber;
    obj.time                    = datenum(vec.timeRapid);
    obj.data                    = cat(2,vec.velocity,vec.analogInput1,vec.analogInput2);
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [26,27,28,20,21];
end