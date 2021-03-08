function obj = applyMeasuringDeviceConfiguration(obj)

	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: applying %s measuring device(s) configuration... \n',char(obj.gearType));
	end
    
    fName = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',char(obj.gearType),'_measuringDevicesConfiguration.xlsx'];
    try
        tbl = DataKit.importTableFile(fName);
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                % Do nothing as the existance of the file is optional
                return
            otherwise
                rethrow(ME)
        end
    end
    tbl     = tbl(tbl{:,'Cruise'} == obj.cruise & ...
                  tbl{:,'Gear'} == obj.gear,:);
	for row = 1:size(tbl,1)
        % find relevant variables
        [poolIdx,variableIdx] = obj.data.findVariable('VariableMeasuringDevice.Type',char(tbl{row,'Type'}),'VariableMeasuringDevice.SerialNumber',char(tbl{row,'SerialNumber'}),'-and','Variable.Id',tbl{row,'Variable'});

        % set new measurment device metadata
        for vv = 1:numel(variableIdx)
            obj.data = obj.data.setMeasuringDeviceProperty(poolIdx(vv),variableIdx(vv),'Type',char(tbl{row,'TypeNew'}));
            obj.data = obj.data.setMeasuringDeviceProperty(poolIdx(vv),variableIdx(vv),'SerialNumber',char(tbl{row,'SerialNumberNew'}));
        end
	end
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: applying %s measuring device(s) configuration... done\n',char(obj.gearType));
	end
end
