function obj = loadobj(s)

    import DebuggerKit.Debugger.printDebugMessage
    
    
    switch s.gearType
        case 'BIGO'
            obj         = GearKit.bigoDeployment();
            metadata	= eval('?GearKit.bigoDeployment');
        case 'EC'
            obj         = GearKit.ecDeployment();
            metadata	= eval('?GearKit.ecDeployment');
        otherwise
            error('Dingi:GearKit:gearDeployment:loadobj:invalidGearType',...
                'Invalid or unknown gearType ''%s''.',char(s.gearType))
    end

    propertyNames   = {metadata.PropertyList.Name}';
    needsLoading    = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                cat(1,metadata.PropertyList.Constant),...
                                cat(1,metadata.PropertyList.Dependent)),2));
    nProperties     = numel(needsLoading);
                            
    for pp = 1:nProperties
        printDebugMessage('Verbose','Loading property %u of %u: ''%s''...',pp,nProperties,propertyNames{needsLoading(pp)})
        
        obj.(propertyNames{needsLoading(pp)}) = s.(propertyNames{needsLoading(pp)});
    end

    currentVersion  = getToolboxVersion();
    savedVersion    = s.toolboxVersion;
    deltaVersion    = compareSemanticVersion(currentVersion,savedVersion);
    if deltaVersion == 0
        % versions are equal
    elseif deltaVersion == 1
        % currentVersion > savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:olderSavedVersion',...
            'Warning','The %s deployment was saved with an older toolbox version (%s) than the current one (%s).',char(obj.gearType),savedVersion,currentVersion)
    elseif deltaVersion == -1
        % currentVersion < savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:newerSavedVersion',...
            'Warning','The %s deployment was saved with a newer toolbox version (%s) than the current one (%s).',char(obj.gearType),savedVersion,currentVersion)
    end
end
