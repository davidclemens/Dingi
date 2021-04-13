function assignMeasuringDeviceMountingData(obj)
% ASSIGNMEASURINGDEVICEMOUNTINGDATA

    import DataKit.importTableFile
    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','Assigning %s measuring device(s) mounting locations...',char(obj.gearType))

    measuringDeviceDataFile  = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',char(obj.gearType),'_measuringDevices.xlsx'];
    try
        measuringDeviceData	= importTableFile(measuringDeviceDataFile);
        measuringDeviceData	= measuringDeviceData(measuringDeviceData{:,'Cruise'} == obj.cruise & ...
                                                  measuringDeviceData{:,'Gear'} == obj.gear,:);
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                warning('Dingi:GearKit:gearDeployment:assignMeasuringDeviceMountingData:missingMeasuringDevicesMetadata',...
                    'no measuring devices metadata file found for %s %s',char(obj.cruise),char(obj.gear))
            otherwise
                rethrow(ME);
        end
    end

    maskMatches = obj.data.Index{:,'MeasuringDevice'} == cellstr(measuringDeviceData{:,{'Type','SerialNumber'}});
    
    dataPoolIndex  = obj.data.Index{:,'DataPool'};
    measuringDeviceIndex = obj.data.Index{:,'VariableIndex'};
    for md = 1:size(obj.data.Index,1)
        dp  = dataPoolIndex(md);
        mdi = measuringDeviceIndex(md);
        if sum(maskMatches(md,:)) == 1
            setMeasuringDeviceProperty(obj.data,dp,mdi,'MountingLocation',measuringDeviceData{maskMatches(md,:),'MountingLocation'}{:});
            setMeasuringDeviceProperty(obj.data,dp,mdi,'WorldDomain',char(measuringDeviceData{maskMatches(md,:),'WorldDomain'}));
            setMeasuringDeviceProperty(obj.data,dp,mdi,'DeviceDomain',char(measuringDeviceData{maskMatches(md,:),'DeviceDomain'}));
        else
            tmpMd = obj.data.Info(dp).VariableMeasuringDevice(mdi);
            if isempty(tmpMd.MountingLocation) || isempty(tmpMd.WorldDomain) || isempty(tmpMd.DeviceDomain)
                warning('Dingi:GearKit:gearDeployment:assignMeasuringDeviceMountingData:noMountingLocationFound',...
                    'There is no mounting data defined in\n\t%s\nfor\n\t%s\n',measuringDeviceDataFile,strjoin({char(obj.data.Index{md,'MeasuringDevice'}.Type),obj.data.Index{md,'MeasuringDevice'}.SerialNumber},' '))
            end
        end
    end

    printDebugMessage('Info','Assigning %s measuring device(s) mounting locations... done',char(obj.gearType))
end
