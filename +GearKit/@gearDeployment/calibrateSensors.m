function obj = calibrateSensors(obj)
    
    import GearKit.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: calibrating %s sensor(s)... \n',obj.gearType);
	end
    
    obj.calibration{:,'CalibrationTime'} = mean(obj.calibration{:,{'CalibrationStart','CalibrationEnd'}},2);
    
    [uSignals,~,uSignalsInd] = unique(obj.calibration(:,{'Cruise','Gear','SensorId','SerialNumber','SignalParameterId'}),'rows');

    % loop over all available calibration signals. A signal is a unique
    % calibration time-data pair for which calibration information exists.
    for sig = 1:size(uSignals,1)
        % create logical indecies (LI) and indices (I)
        maskCalibration     = uSignalsInd == sig; % LI calibration table
        maskCalibrationInd  = find(maskCalibration); % I calibration table
        maskSensors         = {obj.sensors.id}' == uSignals{sig,'SensorId'} & ...
                              {obj.sensors.serialNumber}' == uSignals{sig,'SerialNumber'}; % LI sensor array
        maskSensorsInd   	= find(maskSensors); % I sensor array
        
        if isempty(maskSensorsInd)
            warning('GearKit:gearDeployment:calibrateSensors:sensorNotFound',...
                'While trying to apply the following calibration data\n\t%s,\nthe sensor was not found. Calibration is skipped.',strjoin(cellstr(uSignals{sig,:}),' '))
            continue
        else
            % NOTE: the column order of sensor.data is assumed to be the same between sensors of the same type
            maskDataName        = obj.sensors(find(maskSensors,1)).dataInfo.id == uSignals{sig,'SignalParameterId'}; % LI data names in sensor array
        end
          
        % if no calibration signal is provided it should be read from the sensor data first
        if all(isnan(obj.calibration{maskCalibration,'Signal'})) % 
            time    = datenum(cat(1,obj.sensors(maskSensors).time));
            data    = cat(1,obj.sensors(maskSensors).dataRaw);
            data    = data(:,maskDataName);
            
            % write the mean signal over the calibration period to the calibration table
            for ii = 1:sum(maskCalibration)
                maskTime    = time >= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationStart'}) & ...
                              time <= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationEnd'});
                if isempty(maskTime)
                    warning('GearKit:gearDeployment:calibrateSensors:noCalibrationSignalAvailable',...
                        'No calibration signal data available for for the specified times.')
                end
                obj.calibration{maskCalibrationInd(ii),'Signal'}    = nanmean(data(maskTime));
            end
        end
        
        % extract relevant calibration data from calibration table
        timeCal = datenum(obj.calibration{maskCalibration,'CalibrationTime'});
        signal  = obj.calibration{maskCalibration,'Signal'};
        value 	= obj.calibration{maskCalibration,'Value'};
        
        func        = fitLinear([timeCal,signal],value);
        
        for sens = 1:numel(maskSensorsInd)
            obj.sensors(maskSensorsInd(sens)).dataInfo.calibrationFunction{maskDataName}    = func;
            obj.sensors(maskSensorsInd(sens)).dataInfo.idRaw(maskDataName)                  = obj.sensors(maskSensorsInd(sens)).dataInfo.id(maskDataName); % copy old parameter name to nameRaw
            obj.sensors(maskSensorsInd(sens)).dataInfo.id(maskDataName)                     = obj.calibration{maskCalibrationInd(1),'ValueParameterId'};
            
            obj.sensors(maskSensorsInd(sens)).data(:,maskDataName)                          = func([datenum(obj.sensors(maskSensorsInd(sens)).time),obj.sensors(maskSensorsInd(sens)).dataRaw(:,maskDataName)]);
        end
    end
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: calibrating %s sensor(s)... done\n',obj.gearType);
	end
end