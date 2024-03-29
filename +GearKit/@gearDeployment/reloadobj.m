function obj = reloadobj(obj,s)

    import DebuggerKit.Debugger.printDebugMessage
    import UtilityKit.Utilities.toolbox.*
    
    propertyNames   = {...
        'data',...
        'HardwareConfiguration',...
        'gearType',...
        'cruise',...
        'gear',...
        'station',...
        'areaId',...
        'longitude',...
        'latitude',...
        'depth',...
        'timeDeployment',...
        'timeRecovery',...
        'timeOfInterestStart',...
        'timeOfInterestEnd',...
        'calibration',...
        'analysis',...
        'dataFolderInfo',...
        'dataVersion',...
        'SaveFile',...
        'LoadFile'...
        };
    nProperties     = numel(propertyNames);
    
    for pp = 1:nProperties
        printDebugMessage('Verbose','gearDeployment: Loading property %u of %u: ''%s''...',pp,nProperties,propertyNames{pp})

        obj.(propertyNames{pp}) = s.(propertyNames{pp});
    end

    % Compare toolbox versions of saved instance with current instance
    toolboxVersionCurrent	= toolbox.version('Dingi');
    toolboxVersionSaved     = s.toolboxVersion;
    deltaVersion            = compareSemanticVersion(toolboxVersionCurrent,toolboxVersionSaved);
    if deltaVersion == 0
        % versions are equal
    elseif deltaVersion == 1
        % currentVersion > savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:olderSavedVersion',...
            'Warning','The %s deployment was saved with an older toolbox version (%s) than the current one (%s).',char(obj.gearType),toolboxVersionSaved,toolboxVersionCurrent)
    elseif deltaVersion == -1
        % currentVersion < savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:newerSavedVersion',...
            'Warning','The %s deployment was saved with a newer toolbox version (%s) than the current one (%s).',char(obj.gearType),toolboxVersionSaved,toolboxVersionCurrent)
    end

    % Compare data structure versions of saved instance with current instance
    dataStructVersionCurrent	= obj.DataStructureVersion;
    dataStructVersionSaved      = s.DataStructureVersion;
    deltaVersion                = compareSemanticVersion(dataStructVersionCurrent,dataStructVersionSaved);
    if deltaVersion == 0
        % versions are equal
    elseif deltaVersion == 1
        % currentVersion > savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:olderSavedVersion',...
            'Warning','The %s deployment was saved with an older data structure version (%s) than the current one (%s).',char(obj.gearType),dataStructVersionSaved,dataStructVersionCurrent)
    elseif deltaVersion == -1
        % currentVersion < savedVersion
        printDebugMessage('Dingi:GearKit:gearDeployment:loadobj:newerSavedVersion',...
            'Warning','The %s deployment was saved with a newer data structure version (%s) than the current one (%s).',char(obj.gearType),dataStructVersionSaved,dataStructVersionCurrent)
    end
end
