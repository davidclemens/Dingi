function varargout = readNortekVector(obj,path)

    import ECToolbox.*
    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)

  	vec         = NortekVecFile(path);

	measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'NortekVector';
    measuringDevice.SerialNumber  	= vec.HardwareConfiguration.serialNumber;

    variables               = {'Time','VelocityU','VelocityV','VelocityW','AnalogInput1','AnalogInput2','BeamCorrelation1','BeamCorrelation2','BeamCorrelation3','SignalToNoiseRatio1','SignalToNoiseRatio2','SignalToNoiseRatio3'};
    data                    = cat(2,seconds(vec.timeRapid - vec.timeRapid(1)),vec.velocity,vec.analogInput1,vec.analogInput2,vec.correlation,vec.snr);
    variableType            = {'Independent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent','Dependent'};
    variableOrigin          = {vec.timeRapid(1), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));

    if sum(vec.errorCode) > 0
        printDebugMessage('Warning','There were some error codes found in the Vector data. Please review.')
    end
    
    obj.addVariable(variables,data,...
        'VariableType',             variableType,...
        'VariableOrigin',           variableOrigin,...
        'VariableMeasuringDevice',	variableMeasuringDevice);

	if nargout == 1
        varargout{1} = obj;
	end
end
