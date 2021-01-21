function assignMeasuringDeviceMountingData(obj)
% ASSIGNMEASURINGDEVICEMOUNTINGDATA

    import DataKit.importTableFile
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: assigning %s measuring device(s) mounting locations... \n',obj.gearType);
	end
    
    measuringDeviceDataFile  = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_measuringDevices.xlsx'];
    try
        measuringDeviceData	= importTableFile(measuringDeviceDataFile);
        measuringDeviceData	= measuringDeviceData(measuringDeviceData{:,'Cruise'} == obj.cruise & ...
                                                  measuringDeviceData{:,'Gear'} == obj.gear,:);
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                warning('GearKit:gearDeployment:assignMeasuringDeviceMountingData:missingMeasuringDevicesMetadata',...
                    'no measuring devices metadata file found for %s %s',char(obj.cruise),char(obj.gear))
            otherwise
                rethrow(ME);
        end
    end
    
    maskMatches = obj.data.Index{:,'MeasuringDevice'} == cellstr(measuringDeviceData{:,{'Type','SerialNumber'}});
    for md = 1:size(obj.data.Index,1)
        dp  = obj.data.Index{md,'DataPool'};
        mdi = obj.data.Index{md,'VariableIndex'};
        if sum(maskMatches(md,:)) == 1
            obj.data = setMeasuringDeviceProperty(obj.data,dp,mdi,'MountingLocation',measuringDeviceData{maskMatches(md,:),'MountingLocation'}{:});
            obj.data = setMeasuringDeviceProperty(obj.data,dp,mdi,'WorldDomain',char(measuringDeviceData{maskMatches(md,:),'WorldDomain'}));
            obj.data = setMeasuringDeviceProperty(obj.data,dp,mdi,'DeviceDomain',char(measuringDeviceData{maskMatches(md,:),'DeviceDomain'}));
        else
            warning('GearKit:gearDeployment:assignMeasuringDeviceMountingData:noMountingLocationFound',...
                'There is no mounting data defined in\n\t%s\nfor\n\t%s\n',measuringDeviceDataFile,strjoin({obj.sensors(md).id,obj.sensors(md).serialNumber},' '))
        end
    end
    
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: assigning %s measuring device(s) mounting locations... done\n',obj.gearType);
	end
end