function obj = readNortekVector(obj,path)

    import ECToolbox.*

  	vec         = NortekVecFile(path);
    
	measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'NortekVector';
    measuringDevice.SerialNumber  	= vec.HardwareConfiguration.serialNumber;
                
          
	pool                    = obj.PoolCount;
    variables               = {'Time','VelocityU','VelocityV','VelocityW','AnalogInput1','AnalogInput2'};
    data                    = cat(2,seconds(vec.timeRapid - vec.timeRapid(1)),vec.velocity,vec.analogInput1,vec.analogInput2);
    uncertainty             = [];
    variableType            = {'Independant','Dependant','Dependant','Dependant','Dependant','Dependant'};
    variableOrigin          = {vec.timeRapid(1), 0, 0, 0, 0, 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));
    
    obj	= obj.addVariable(pool,variables,data,uncertainty,...
            'VariableType',             variableType,...
            'VariableOrigin',           variableOrigin,...
            'VariableMeasuringDevice',	variableMeasuringDevice);
end