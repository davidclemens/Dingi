function data = getData(obj,variable,varargin)


    % parse Name-Value pairs
    optionName          = {'ReturnAbsoluteValues','Raw','DataPoolIdx'}; % valid options (Name)
    optionDefaultValue  = {false,false,[]}; % default value (Value)
    [...
     returnAbsoluteValues,... 	% return data with the dataOrigin taken into account
     raw,...                    % return uncalibrated data
     dataPoolIdx...             % return only data from the specified data pool
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 

	% input check: parameter
    if ischar(variable)
        variable	= cellstr(variable);
    elseif isnumeric(variable) || iscellstr(variable)
        variable	= variable(:);
    elseif isa(variable,'DataKit.Metadata.variable')
        variable	= variable2str(variable(:));
    else
        error('DataKit:dataPool:getData:invalidVariableType',...
         	'The requested variable has to be specified as a char, cellstr or variable id.')
    end
    
    % check that at least 1 variable exists
    if all(cat(2,obj.Info.VariableCount) == 0)
        error('DataKit:dataPool:getData:emptyDataPool',...
            'There is no data in the data pool')
    end
    
    % get all independant variables
    [iData,iInfo]	= gd(obj,'Independant',[],...
                        'ReturnAbsoluteValues',     returnAbsoluteValues,...
                        'Raw',                      raw,...
                        'DataPoolIdx',              dataPoolIdx);
	% get all requested dependant variables
    [dData,dInfo]   = gd(obj,'Dependant',variable,...
                        'ReturnAbsoluteValues',     returnAbsoluteValues,...
                        'Raw',                      raw,...
                        'DataPoolIdx',              dataPoolIdx);                    
                    
	% remove data pools that hold no data
    dataPoolHasData = find(any(~cellfun(@isempty,dData),2));
    iData           = iData(dataPoolHasData,:);
    dData           = dData(dataPoolHasData,:);
    iInfo.VariableOrigin    = iInfo.VariableOrigin(dataPoolHasData,:);
    dInfo.VariableOrigin    = dInfo.VariableOrigin(dataPoolHasData,:);
    iInfo.MeasuringDevice   = iInfo.MeasuringDevice(dataPoolHasData);
    dInfo.MeasuringDevice   = dInfo.MeasuringDevice(dataPoolHasData);
                 
    % aggregate output
    data                        = struct();
    data.IndependantVariables   = iData;
    data.DependantVariables     = dData;
    data.IndependantInfo        = iInfo;
    data.DependantInfo          = dInfo;
end