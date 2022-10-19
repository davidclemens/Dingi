function getGearDeploymentMetadata(obj,pathName)
% GETGEARDEPLOYMENTMETADATA

    import DebuggerKit.Debugger.printDebugMessage
    import UtilityKit.Utilities.table.readTableFile
    
 	printDebugMessage('Info','Extracting %s deployment metadata...',char(obj.gearType))

    % support empty initializeation of gearDeployment subclasses
    if isempty(pathName)
        return
    end

    [~,obj.dataFolderInfo.gearName,~]  	= fileparts(pathName);
    obj.dataFolderInfo.dataFolder       = pathName;
    tmpRootFolder                       = strsplit(pathName,'/');
    obj.dataFolderInfo.rootFolder       = strjoin(tmpRootFolder(1:end - 2),'/');

    ids	= regexp(pathName,['(?<cruise>[A-Z]+\d+)_',char(obj.gearType),'_data(_)?(?<version>v\d+)?/(?<gear>',char(obj.gearType),'.+)$'],'names');

    obj.dataVersion = ids.version;
    obj.cruise      = categorical({ids.cruise});
    switch obj.gearType
        case 'BIGO'
            obj.gear	= categorical({regexprep(ids.gear,'^BIGO\-(I{1,2})','BIGO${num2str(numel($1))}','once')});
        case 'EC'
            obj.gear    = categorical({ids.gear});
    end

    deploymentMetadataFile  = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',char(obj.gearType),'_deployments.xlsx'];
    try
        deploymentMetadata     	= readTableFile(deploymentMetadataFile);
        deploymentMetadata      = deploymentMetadata(deploymentMetadata{:,'Cruise'} == obj.cruise & ...
                                                     deploymentMetadata{:,'Gear'} == obj.gear,:);
        if size(deploymentMetadata,1) ~= 1
            printDebugMessage('Dingi:GearKit:gearDeployment:getGearDeploymentMetadata:multipleDeploymentMatches',...
                'FatalError','Multiple deployment metadata matches for %s %s',char(obj.cruise),char(obj.gear)')
        end
        obj.areaId              = deploymentMetadata{1,'TransectID'};
        obj.station             = deploymentMetadata{1,'StationDepl'};
        obj.longitude           = deploymentMetadata{1,'Lon'};
        obj.latitude            = deploymentMetadata{1,'Lat'};
        obj.depth               = deploymentMetadata{1,'Depth'};
        obj.timeDeployment      = deploymentMetadata{1,'DeplTime'};
        obj.timeRecovery        = deploymentMetadata{1,'RecTime'};
        obj.timeOfInterestStart	= obj.timeDeployment;
        obj.timeOfInterestEnd  	= obj.timeRecovery;
    catch ME
        switch ME.identifier
            case 'Utilities:table:readTableFile:InvalidFile'
                printDebugMessage('Dingi:GearKit:gearDeployment:getGearDeploymentMetadata:missingDeploymentMetadataFile',...
                  	'Warning','No deployment metadata file found for %s %s',char(obj.cruise),char(obj.gear))
            otherwise
                rethrow(ME);
        end
    end

    printDebugMessage('Info','Extracting %s deployment metadata... done',char(obj.gearType));
end
