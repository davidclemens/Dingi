function data = fetchVariableData(obj,poolIdx,variableIdx,varargin)

    
    % parse Name-Value pairs
    optionName          = {'ReturnRawData','ForceCellOutput'}; % valid options (Name)
    optionDefaultValue  = {false,true}; % default value (Value)
    [...
     returnRawData,...                      %
     forceCellOutput...
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
    if ~isnumeric(poolIdx) || ~isnumeric(variableIdx)
        error('DataKit:dataPool:fetchVariableData:nonNumericIdx',...
            'Indices have to be numeric.')
    end
    if any(poolIdx > obj.PoolCount)
        error('DataKit:dataPool:fetchVariableData:invalidPoolIndex',...
            'Data pool index exceeds number of pools.')
    end
    if any(variableIdx > cat(1,obj.Info(poolIdx).VariableCount))
        error('DataKit:dataPool:fetchVariableData:invalidVariableIndex',...
            'Variable index exceeds number of variables in data pool.')
    end
    if ~isvector(poolIdx) || ~isvector(variableIdx)
        error('DataKit:dataPool:fetchVariableData:nonVectorIdx',...
            'Vector indices required.')
    end
    
    % reshape to only deal with column vectors
    poolIdx     = reshape(poolIdx,[],1);
    variableIdx	= reshape(variableIdx,[],1);
    
    sPoolIdx        = size(poolIdx);
    sVariableIdx    = size(variableIdx);
    
    % grow vectors to match if necessary 
    if sPoolIdx(1) == 1 && sVariableIdx(1) > 1
        poolIdx = repmat(poolIdx,sVariableIdx(1),1);
    elseif sPoolIdx(1) > 1 && sVariableIdx(1) == 1
        variableIdx = repmat(variableIdx,sPoolIdx(1),1);
    elseif sPoolIdx(1) == 1 && sVariableIdx(1) == 1
        % ok
    elseif sPoolIdx(1) > 1 && sVariableIdx(1) == sPoolIdx(1)
        % ok
    else
        error('DataKit:dataPool:fetchVariableData:mismatchingIdxShape',...
            'The shape of the index vectors mismatch.')
    end
    nVariables  = numel(variableIdx);
    
    if returnRawData
        data = arrayfun(@(p,v) obj.DataRaw{p}(:,v),poolIdx,variableIdx,'un',0);
    else
        data = arrayfun(@(p,v) obj.Data{p}(:,v),poolIdx,variableIdx,'un',0);
    end
    origin  = arrayfun(@(p,v) obj.Info(p).VariableOrigin{v},poolIdx,variableIdx,'un',0);
    
    for ii = 1:numel(poolIdx)
        switch obj.Info(poolIdx(ii)).VariableReturnDataType(variableIdx(ii))
            case 'datetime'
                data{ii} = origin{ii} + seconds(data{ii});
            case {'double','single'}
                data{ii} = origin{ii} + data{ii};
            otherwise
                error('DataKit:dataPool:fetchVariableData:unknownVariableReturnType',...
                    'Variable return type ''%s'' not implemented yet.',char(obj.Info(poolIdx(ii)).VariableReturnDataType(variableIdx(ii))))
        end
    end
    
    if nVariables == 1 && ~forceCellOutput
        data    = data{:};
    end
end