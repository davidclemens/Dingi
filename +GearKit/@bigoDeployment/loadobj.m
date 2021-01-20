function obj = loadobj(s)
    
    import GearKit.bigoDeployment
    
    metadata        = eval('?GearKit.bigoDeployment');
    propertyNames   = {metadata.PropertyList.Name}';
    needsLoading    = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                cat(1,metadata.PropertyList.Constant),...
                                cat(1,metadata.PropertyList.Dependent)),2));    
    
    obj = bigoDeployment();
    
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
        warning('GearKit:bigoDeployment:loadobj:olderSavedVersion',...
            'The %s deployment was saved with an older toolbox version (%s) than the current one (%s).',obj.gearType,savedVersion,currentVersion)
    elseif deltaVersion == -1
        % currentVersion < savedVersion
        warning('GearKit:bigoDeployment:loadobj:newerSavedVersion',...
            'The %s deployment was saved with a newer toolbox version (%s) than the current one (%s).',obj.gearType,savedVersion,currentVersion)
    end
end