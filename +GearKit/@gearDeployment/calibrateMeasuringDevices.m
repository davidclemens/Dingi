function obj = calibrateMeasuringDevices(obj)
    
    import GearKit.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: calibrating %s measuring device(s)... \n',obj.gearType);
	end
    
    obj.calibration{:,'CalibrationTime'} = mean(obj.calibration{:,{'CalibrationStart','CalibrationEnd'}},2);
    
    [uSignals,~,uSignalsInd] = unique(obj.calibration(:,{'Cruise','Gear','Type','SerialNumber','SignalVariableId'}),'rows');

    % loop over all available calibration signals. A signal is a unique
    % calibration time-data pair for which calibration information exists.
    for sig = 1:size(uSignals,1)
        % create logical indecies (LI) and indices (I)
        maskCalibration         = uSignalsInd == sig; % LI calibration table
        maskCalibrationInd      = find(maskCalibration); % I calibration table
        
        
        maskMeasuringDevices  	= obj.data.Index{:,'MeasuringDevice'} == cellstr(uSignals{sig,{'Type','SerialNumber'}}) & ...
                                  (cat(1,obj.data.Index{:,'VariableRaw'}.Id) == uSignals{sig,'SignalVariableId'} | ...
                                   cat(1,obj.data.Index{:,'Variable'}.Id) == uSignals{sig,'SignalVariableId'});
        
        maskMeasuringDevicesInd	= find(maskMeasuringDevices);
        
        if isempty(maskMeasuringDevicesInd)
            warning('GearKit:gearDeployment:calibrateMeasuringDevices:measuringDeviceNotFound',...
                'While trying to apply the following calibration data\n\t%s,\nthe measuring device was not found. Calibration is skipped.',strjoin(cellstr(uSignals{sig,:}),' '))
            continue
        elseif numel(maskMeasuringDevicesInd) > 1
%             error('Test this scenario')
        end
          
        % if no calibration signal is provided it should be read from the sensor data first
        if all(isnan(obj.calibration{maskCalibration,'Signal'}))            
            uRequestedVariableId  = unique(variable2id(obj.data.Index{maskMeasuringDevices,'Variable'}));
            
            data   = fetchData(obj.data,uRequestedVariableId,[],obj.data.Index{maskMeasuringDevices,'MeasuringDevice'},...
                                'ReturnRawData',        true,...
                                'GroupBy',              'MeasuringDevice');
                            
            maskIndependantData     = data.IndepInfo.Variable == 'Time';
            iData       = datenum(cat(1,data.IndepData{:,maskIndependantData}));
            dData       = cat(1,data.DepData);
            % write the mean signal over the calibration period to the calibration table
            for ii = 1:sum(maskCalibration)
                maskTime    = iData >= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationStart'}) & ...
                              iData <= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationEnd'});
                if isempty(maskTime)
                    warning('GearKit:gearDeployment:calibrateMeasuringDevices:noCalibrationSignalAvailable',...
                        'No calibration signal data available for for the specified times.')
                elseif sum(diff(maskTime) == 1) < 1 || sum(diff(maskTime) == -1) < 1
                    warning('GearKit:gearDeployment:calibrateMeasuringDevices:incompleteCalibrationSignalCoverage',...
                        'The calibration signal available doesn''t cover the entire calibration period.')
                end
                obj.calibration{maskCalibrationInd(ii),'Signal'}    = nanmean(dData(maskTime));
            end
        end
        
        % extract relevant calibration data from calibration table
        timeCal         = obj.calibration{maskCalibration,'CalibrationTime'};
        timeOrigin      = datenum(min(timeCal));
        time          	= datenum(timeCal) - timeOrigin;
        signal          = obj.calibration{maskCalibration,'Signal'};
        value           = obj.calibration{maskCalibration,'Value'};
        
        [~,linearCoefficients]	= fitLinear([time,signal],value);
        calibrationFunction    	= @(Time,Signal) cat(2,ones(size(Time,1),1),Time - timeOrigin,Signal)*linearCoefficients;
        
        [~,valueVariableInfo] 	= DataKit.Metadata.variable.validateId(obj.calibration{find(maskCalibration,1),'ValueVariableId'});
        
        pool        = obj.data.Index{maskMeasuringDevicesInd,'DataPool'};
        var         = obj.data.Index{maskMeasuringDevicesInd,'VariableIndex'};
        
        for v = 1:numel(pool)
            % set calibration function
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'VariableCalibrationFunction',{calibrationFunction});
            
            % update variable to the calibrated variable
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'VariableRaw',obj.data.Info(pool(v)).Variable(var(v)));
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'Variable',valueVariableInfo{:,'Variable'});
        end
    end
    obj.data    = update(obj.data);
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: calibrating %s measuring device(s)... done\n',obj.gearType);
	end
end