function varargout = readNortekVector(obj,path)

    import ECToolbox.*

    nargoutchk(0,1)

  	vec         = NortekVecFile(path);

	measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'NortekVector';
    measuringDevice.SerialNumber  	= vec.HardwareConfiguration.serialNumber;

    variables               = {'Time','VelocityU','VelocityV','VelocityW','AnalogInput1','AnalogInput2'};
    data                    = cat(2,seconds(vec.timeRapid - vec.timeRapid(1)),vec.velocity,vec.analogInput1,vec.analogInput2);
    variableType            = {'Independant','Dependant','Dependant','Dependant','Dependant','Dependant'};
    variableOrigin          = {vec.timeRapid(1), 0, 0, 0, 0, 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));

    obj.addVariable(variables,data,...
        'VariableType',             variableType,...
        'VariableOrigin',           variableOrigin,...
        'VariableMeasuringDevice',	variableMeasuringDevice);

	if nargout == 1
        varargout{1} = obj;
	end
end
