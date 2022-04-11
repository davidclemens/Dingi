function determineHardwareConfiguration(obj)
% DETERMINEHARDWARECONFIGURATION
    
    import DataKit.importTableFile
    import GearKit.hardwareConfiguration
    
    obj.HardwareConfiguration   = hardwareConfiguration(obj);
    
    RecoveryTable       = importTableFile([obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_BIGO_recovery.xlsx']);
    
    % Get chamber data
    indRecoveryTable    = find(all(RecoveryTable{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2));
    maskChamberHeights 	= ~cellfun(@isempty,regexp(RecoveryTable.Properties.VariableNames,'ChH(\d+|SZ)'));
    
    chamberArea       	= pi.*(RecoveryTable{indRecoveryTable,'ChDia'}./2.*1e-2).^2; % m^2
    chamberHeight       = nanmean(RecoveryTable{indRecoveryTable,maskChamberHeights},2); % cm
    
    chamberData         = table();
    
    chamberData.DeviceDomain            = GearKit.deviceDomain.fromProperty('Abbreviation',char(RecoveryTable{indRecoveryTable,'Subgear'}));
    chamberData.Height                  = chamberHeight;
    chamberData.Area                    = chamberArea;
    chamberData.VolumeViaHeight         = chamberArea.*1e2.*chamberHeight.*1e-1;
    chamberData.VolumeViaConductivity	= NaN(size(indRecoveryTable));
    chamberData.VolumeMethod            = repmat({'ViaHeight'},size(indRecoveryTable));
    
    obj.HardwareConfiguration.DeviceDomainMetadata	= chamberData;
end