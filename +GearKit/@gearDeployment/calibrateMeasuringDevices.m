function calibrateMeasuringDevices(obj)

    import GearKit.*
    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','Calibrating %s measuring device(s)...',char(obj.gearType))

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
            warning('Dingi:GearKit:gearDeployment:calibrateMeasuringDevices:measuringDeviceNotFound',...
                'While trying to apply the following calibration data\n\t%s,\nthe measuring device was not found. Calibration is skipped.',strjoin(cellstr(uSignals{sig,{'Cruise','Gear','Type','SerialNumber'}}),' '))
            continue
        elseif numel(maskMeasuringDevicesInd) > 1
            %
        end

        % if no calibration signal is provided it should be read from the sensor data first
        if all(isnan(obj.calibration{maskCalibration,'Signal'}))
            uRequestedVariableId  = unique(toProperty(obj.data.Index{maskMeasuringDevices,'Variable'},'Id'));

            data   = fetchData(obj.data,uRequestedVariableId,[],obj.data.Index{maskMeasuringDevices,'MeasuringDevice'},...
                                'ReturnRawData',        true,...
                                'GroupBy',              'MeasuringDevice');

            maskIndependantData     = data.IndepInfo.Variable{:} == 'Time';
            iData       = datenum(cat(1,data.IndepData{:,maskIndependantData}));
            dData       = cat(1,data.DepData);
            % write the mean signal over the calibration period to the calibration table
            for ii = 1:sum(maskCalibration)
                maskTime    = iData >= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationStart'}) & ...
                              iData <= datenum(obj.calibration{maskCalibrationInd(ii),'CalibrationEnd'});
                if isempty(maskTime)
                    warning('Dingi:GearKit:gearDeployment:calibrateMeasuringDevices:noCalibrationSignalAvailable',...
                        'No calibration signal data available for for the specified times.')
                elseif sum(diff(maskTime) == 1) < 1 || sum(diff(maskTime) == -1) < 1
                    warning('Dingi:GearKit:gearDeployment:calibrateMeasuringDevices:incompleteCalibrationSignalCoverage',...
                        'The calibration signal available doesn''t cover the entire calibration period.')
                end
                obj.calibration{maskCalibrationInd(ii),'Signal'}    = nanmean(dData(maskTime));
            end
        end

        % extract relevant calibration data from calibration table
        calId           = obj.calibration{maskCalibration,'CalibrationTimeId'};
        timeCal         = obj.calibration{maskCalibration,'CalibrationTime'};
        timeOrigin      = datenum(min(timeCal));
        time          	= datenum(timeCal) - timeOrigin;
        signal          = obj.calibration{maskCalibration,'Signal'};
        value           = obj.calibration{maskCalibration,'Value'};

        calMethod   = 'curvedSurface';
        switch calMethod
            case 'flatSurface'
                [~,linearCoefficients]	= fitLinear([time,signal],value);
                calibrationFunction    	= @(Time,Signal) cat(2,ones(size(Time,1),1),Time - timeOrigin,Signal)*linearCoefficients;
            case 'curvedSurface'
                uCal    = unique(calId);
                nCal    = numel(uCal);
                m       = NaN(nCal,1);
                b       = NaN(nCal,1);
                t       = NaN(nCal,1);

                for cal = 1:nCal
                    maskInd = find(calId == cal);

                    m(cal) = diff(value(maskInd))./diff(signal(maskInd));
                    b(cal) = (value(maskInd(2)).*signal(maskInd(1)) - value(maskInd(1)).*signal(maskInd(2)))/(signal(maskInd(1)) - signal(maskInd(2)));
                    t(cal) = mean(time(maskInd));
                end
                if nCal == 1
                    calibrationFunction	= @(Time,Signal) m.*Signal + b;
                elseif nCal == 2
                    mSl     = diff(m)./diff(t);
                    mInt    = (m(2)*t(1) - m(1)*t(2))/(t(1) - t(2));
                    bSl     = diff(b)./diff(t);
                    bInt    = (b(2)*t(1) - b(1)*t(2))/(t(1) - t(2));

                    calibrationFunction	= @(Time,Signal) (mSl.*(Time - timeOrigin) + mInt).*Signal + (bSl.*(Time - timeOrigin) + bInt);
                elseif nCal > 2
                    error('Dingi:GearKit:gearDeployment:calibrateMeasuringDevices:TODO',...
                      'TODO: not supported yet')
                end
            otherwise
                error('Dingi:GearKit:gearDeployment:calibrateMeasuringDevices:invalidCalibrationMethod',...
                  '''%s'' is an unknown calibration method.',calMethod)
        end

        [~,valueVariableInfo] 	= DataKit.Metadata.variable.validate('Id',obj.calibration{find(maskCalibration,1),'ValueVariableId'});

        pool        = obj.data.Index{maskMeasuringDevicesInd,'DataPool'};
        var         = obj.data.Index{maskMeasuringDevicesInd,'VariableIndex'};

        for v = 1:numel(pool)
            % set calibration function
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'VariableCalibrationFunction',{calibrationFunction});
            obj.data    = obj.data.applyCalibrationFunction(pool(v),var(v));

            % update variable to the calibrated variable
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'VariableRaw',obj.data.Info(pool(v)).Variable(var(v)));
            obj.data	= obj.data.setInfoProperty(pool(v),var(v),'Variable',valueVariableInfo.Variable);
        end
    end

    printDebugMessage('Info','Calibrating %s measuring device(s)... done',char(obj.gearType))
end
