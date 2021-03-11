function readProtocol(obj)
% READPROTOCOL

    protocol    = table();
    
    controlUnits        = dir([obj.dataFolderInfo.dataFolder,'/CHMB*']);
    controlUnits        = reshape({controlUnits.name},[],1);
    controlUnitsPretty  = regexprep(controlUnits,'CHMB(\d)','Ch$1');
    nControlUnits       = numel(controlUnits);
    
    for cu = 1:nControlUnits
        fName       = [obj.dataFolderInfo.dataFolder,'/CHMB',num2str(cu),'/PROTOCOL.TXT'];
        newTbl      = readProtocolFile(fName,obj.dataVersion,controlUnitsPretty{cu});
        newTbl{:,'ControlUnit'} = categorical(controlUnitsPretty(cu));
        protocol	= [protocol;newTbl];
    end
    obj.protocol = sortrows(protocol,{'Time'});
    
    % Add experiment start & end times to the HardwareConfiguration
    events              = {'Experiment Start','Experiment End'};
    eventsVarName       = {'ExperimentStart','ExperimentEnd'};
    defaultEventValue 	= {obj.timeDeployment,obj.timeRecovery};
    nEvents             = numel(events);
    
    % initialize column
    for ev = 1:nEvents
        obj.HardwareConfiguration.DeviceDomainMetadata.(eventsVarName{ev}) = NaT(size(obj.HardwareConfiguration.DeviceDomainMetadata,1),1);
    end
    
    for cu = 1:nControlUnits
        maskHardwareConfiguration 	= ismember({obj.HardwareConfiguration.DeviceDomainMetadata{:,'DeviceDomain'}.Abbreviation}',controlUnitsPretty{cu});
        
        for ev = 1:nEvents
            maskProtocol                = obj.protocol{:,'Event'} == events{ev} & ...
                                          obj.protocol{:,'Subgear'} == controlUnitsPretty{cu};            
            if sum(maskProtocol) == 1
                % use experiment start time if available
                time       = obj.protocol{maskProtocol,'Time'};
            elseif sum(maskProtocol) == 0
                % default to deployment start time if not available
                time       = defaultEventValue{ev};
            else
                error('Dingi:GearKit:bigoDeployment:readProtocol:invalidNumberOfControlUnits',...
                    'Invalid number of control units matching.')
            end
            
            % assign value
            obj.HardwareConfiguration.DeviceDomainMetadata.(eventsVarName{ev})(maskHardwareConfiguration) = time;
        end
    end
    
    % calculate relative times
    obj.protocol{:,'TimeRelative'} = duration(NaN(1,3)); % initialize
 	for cu = 1:nControlUnits
        maskProtocol1   = obj.protocol{:,'ControlUnit'} == controlUnitsPretty{cu};
        maskProtocol2   = maskProtocol1 & ...
                          obj.protocol{:,'Event'} == 'Experiment Start';
        if sum(maskProtocol2) == 1
            obj.protocol{maskProtocol1,'TimeRelative'}  = obj.protocol{maskProtocol1,'Time'} - obj.protocol{maskProtocol2,'Time'};
        else
            error('Dingi:GearKit:bigoDeployment:readProtocol:invalidNumberOfExperimentStarts',...
                'There were %g ''Experiment Start'' events found. Only 1 is valid right now.',sum(maskProtocol2))
        end
  	end
end