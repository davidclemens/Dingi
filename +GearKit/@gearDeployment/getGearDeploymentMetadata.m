function obj = getGearDeploymentMetadata(obj,pathName)
% GETGEARDEPLOYMENTMETADATA

    import DataKit.importTableFile
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: extracting %s deployment metadata... \n',obj.gearType);
	end
    
    [~,obj.dataFolderInfo.gearName,~]  	= fileparts(pathName);
    obj.dataFolderInfo.dataFolder       = pathName;
    tmpRootFolder                       = strsplit(pathName,'/');           
    obj.dataFolderInfo.rootFolder       = strjoin(tmpRootFolder(1:end - 2),'/');
    
    ids	= regexp(pathName,['(?<cruise>[A-Z]+\d+)_',obj.gearType,'_data(_)?(?<version>v\d+)?/(?<gear>',obj.gearType,'.+)$'],'names');

    obj.dataVersion = ids.version;
    obj.cruise      = categorical({ids.cruise});
    switch obj.gearType
        case 'BIGO'
            obj.gear	= categorical({regexprep(ids.gear,'^BIGO\-(I{1,2})','BIGO${num2str(numel($1))}','once')});
        case 'EC'
            obj.gear    = categorical({ids.gear});
        otherwise
            error('GearKit:GearDeployment:getGearDeploymentMetadata:undefinedGearType',...
                'The gear type ''%s'' is not defined yet. Valid gear types are:\n\t%s.',obj.gearType,strjoin(obj.validGearTypes,', '))
    end
    
    deploymentMetadataFile  = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_deployments.xlsx'];
    try
        deploymentMetadata     	= importTableFile(deploymentMetadataFile);
        deploymentMetadata      = deploymentMetadata(deploymentMetadata{:,'Cruise'} == obj.cruise & ...
                                                     deploymentMetadata{:,'Gear'} == obj.gear,:);
        if size(deploymentMetadata,1) ~= 1
            error('GearKit:gearDeployment:getGearDeploymentMetadata:multipleDeploymentMatches',...
                  'multiple deployment metadata matches for ')
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
            case 'MATLAB:xlsread:FileNotFound'
                warning('GearKit:gearDeployment:getGearDeploymentMetadata:missingDeploymentMetadataFile',...
                        'no deployment metadata file found for %s %s',char(obj.cruise),char(obj.gear))
            otherwise
                rethrow(ME);
        end
    end
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: extracting %s deployment metadata... done\n',obj.gearType);
	end
end