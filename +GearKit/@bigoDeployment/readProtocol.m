function obj = readProtocol(obj)
% READPROTOCOL

    uChambers   = fields(obj.chamber);
    nChambers   = numel(uChambers);
    protocol    = table();
    for ch = 1:nChambers
        controlUnit     = ['Ch',num2str(ch)];
        fName       = [obj.dataFolderInfo.dataFolder,'/CHMB',num2str(ch),'/PROTOCOL.TXT'];
        newTbl      = readProtocolFile(fName,obj.dataVersion,controlUnit);
        newTbl{:,'ControlUnit'} = categorical({controlUnit});
        protocol	= [protocol;newTbl];
        
    end
    obj.protocol = sortrows(protocol,{'Time'});
    
    for ch = 1:nChambers
        controlUnit     = ['Ch',num2str(ch)];
        
        parameters      = {'Experiment Start','Experiment End'};
        defaultValue    = {obj.timeDeployment,obj.timeRecovery};
        unit            = {'UTC','UTC'};
        for par = 1:numel(parameters)
            maskProtocol    = obj.protocol{:,'Event'} == parameters{par} & obj.protocol{:,'Subgear'} == controlUnit;
            if sum(maskProtocol) == 1
                time       = obj.protocol{maskProtocol,'Time'};
            elseif sum(maskProtocol) == 0
                time       = defaultValue{par};
            else
                error('GearKit:bigoDeployment:readProtocol:invalidNumberOfControlUnits',...
                    'error')
            end
            nParameter      = numel(fields(obj.chamber.(controlUnit)));
            obj.chamber.(controlUnit)(nParameter + par).Parameter     = parameters{par};
            obj.chamber.(controlUnit)(nParameter + par).Value         = time;
            obj.chamber.(controlUnit)(nParameter + par).Unit          = unit{par};
        end
    end
    
    % calculate relative times
    obj.protocol{:,'TimeRelative'} = duration(NaN,NaN,NaN); % initialize
 	for ch = 1:nChambers
        controlUnit     = ['Ch',num2str(ch)];
        maskProtocol1   = obj.protocol{:,'ControlUnit'} == controlUnit;
        maskProtocol2   = maskProtocol1 & ...
                          obj.protocol{:,'Event'} == 'Experiment Start';
        if sum(maskProtocol2) == 1
            obj.protocol{maskProtocol1,'TimeRelative'}  = obj.protocol{maskProtocol1,'Time'} - obj.protocol{maskProtocol2,'Time'};
        else
            error('GearKit:bigoDeployment:readProtocol:invalidNumberOfExperimentStarts',...
                'There were %g ''Experiment Start'' events found. Only 1 is valid right now.',sum(maskProtocol2))
        end
  	end
end