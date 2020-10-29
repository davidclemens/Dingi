function obj = determineChamberMetadata(obj)
% DETERMINECHAMBERVOLUME
    
    import DataKit.importTableFile
    
    RecoveryTable       = importTableFile([obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_BIGO_recovery.xlsx']);
    
    indRecoveryTable    = find(all(RecoveryTable{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2));
    maskHeights         = ~cellfun(@isempty,regexp(RecoveryTable.Properties.VariableNames,'ChH\d+'));
    
    chamberArea       	= pi.*(RecoveryTable{indRecoveryTable,'ChDia'}./2.*1e-2).^2; % m^2
    chamberHeight       = nanmean(RecoveryTable{indRecoveryTable,maskHeights},2); % cm
    
    chamberData         = struct();
    
    for ch = 1:numel(indRecoveryTable)
        sg      = char(RecoveryTable{indRecoveryTable(ch),'Subgear'});
        ind     = 1;
        chamberData.(sg)(ind).Parameter    = 'area';
        chamberData.(sg)(ind).Value        = chamberArea(ch);
        chamberData.(sg)(ind).Unit         = 'm^2';
        ind     = ind + 1;

        chamberData.(sg)(ind).Parameter    = 'volumeViaHeight';
        chamberData.(sg)(ind).Value        = chamberArea(ch).*1e2.*chamberHeight(ch).*1e-1;
        chamberData.(sg)(ind).Unit         = 'L';
        ind     = ind + 1;

        chamberData.(sg)(ind).Parameter    = 'volumeViaConductivity';
        chamberData.(sg)(ind).Value        = NaN;
        chamberData.(sg)(ind).Unit         = 'L';
        ind     = ind + 1;

        chamberData.(sg)(ind).Parameter    = 'volumeMethod';
        chamberData.(sg)(ind).Value        = 'height';
        chamberData.(sg)(ind).Unit         = '';    
        ind     = ind + 1;    
    end
    
    obj.chamber         = chamberData;
end