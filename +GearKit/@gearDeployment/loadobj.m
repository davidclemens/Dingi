function obj = loadobj(s)
    
    switch s.gearType
        case 'BIGO'
            obj         = GearKit.bigoDeployment();
            metadata	= eval('?GearKit.bigoDeployment');
        case 'EC'
            obj         = GearKit.ecDeployment();
            metadata	= eval('?GearKit.ecDeployment');
        otherwise
            error('Dingi:GearKit:gearDeployment:loadobj:invalidGearType',...
                'Invalid or unknown gearType ''%s''.',s.gearType)
    end
    
    propertyNames   = {metadata.PropertyList.Name}';
    needsLoading    = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                cat(1,metadata.PropertyList.Constant),...
                                cat(1,metadata.PropertyList.Dependent)),2));    
    
    for pp = 1:numel(needsLoading)
        obj.(propertyNames{needsLoading(pp)}) = s.(propertyNames{needsLoading(pp)});
    end
    
    currentVersion  = getToolboxVersion();
    savedVersion    = s.toolboxVersion;
    deltaVersion    = compareSemanticVersion(currentVersion,savedVersion);
    if deltaVersion == 0
        % versions are equal
    elseif deltaVersion == 1
        % currentVersion > savedVersion
        warning('Dingi:GearKit:gearDeployment:loadobj:olderSavedVersion',...
            'The %s deployment was saved with an older toolbox version (%s) than the current one (%s).',obj.gearType,savedVersion,currentVersion)
    elseif deltaVersion == -1
        % currentVersion < savedVersion
        warning('Dingi:GearKit:gearDeployment:loadobj:newerSavedVersion',...
            'The %s deployment was saved with a newer toolbox version (%s) than the current one (%s).',obj.gearType,savedVersion,currentVersion)
    end
end