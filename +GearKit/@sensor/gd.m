function [t,d] = gd(obj,parameter,varargin)
% GD (get data) returns the specified sensor data for a sensor or sensor
% array.

    % parse Name-Value pairs
    optionName          = {'Raw'}; % valid options (Name)
    optionDefaultValue  = {false}; % default value (Value)
    [raw...
     ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    if ~isa(parameter,'uint16')
        error('GearKit:gearDeployment:getSensorData:invalidParameterType',...
              'The requested parameter has to be specified as a uint16.')
    end
   	parameter	= parameter(:);
    
    nParameter  = numel(parameter);
    nObj        = numel(obj);
    
    if nObj <= 0
        error('object is empty')
    end
    
    t       = cell(nObj,1);
    d       = cell(nObj,nParameter);
    for oo = 1:nObj
        
        imParameter = ismember(parameter,obj(oo).dataParameters);
        if all(~imParameter)
            invalidParameterIndex = find(~imParameter,1);
            warning('GearKit:gearDeployment:gd:invalidParameter',...
                  '''%s'' is not a valid parameter for sensor %s. Valid parameters are:\n\t%s\n',char(parameter(invalidParameterIndex)),strjoin({obj(oo).id,obj(oo).serialNumber},' '),strjoin(cellstr(obj(oo).dataParameters),'\n\t'))
            continue
        end
        ind         = parameter == obj(oo).dataParameters;
        [par,dat]   = find([ind;false(1,size(ind,2))]);
        
        
        t{oo,:}	= obj(oo).time;
        if raw
            d(oo,:) 	= accumarray(par,dat,[nParameter,1],@(d) {obj(oo).dataRaw(:,d)},{})';
        else
            d(oo,:) 	= accumarray(par,dat,[nParameter,1],@(d) {obj(oo).data(:,d)},{})';
        end
    end
    
    invalidParameterIndex   = find(all(cellfun(@isempty,d),1),1);
    if ~isempty(invalidParameterIndex)
        error('GearKit:gearDeployment:gd:invalidParameter',...
          '''%s'' is not a valid parameter for any of the sensors. Valid parameters are:\n\t%s\n',char(parameter(invalidParameterIndex)),strjoin(unique(cat(2,obj.dataParameters)),'\n\t'))
    end
end
