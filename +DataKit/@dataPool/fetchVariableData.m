function [data,flags] = fetchVariableData(obj,poolIdx,variableIdx,varargin)
% fetchVariableData  Gathers data from a datapool object by index
%   FETCHVARIABLEDATA returns the data within a datapool object by allowing
%   to specify pairs of pool index and variable index.
%
%   Syntax
%     data = FETCHVARIABLEDATA(dp,poolIdx,variableIdx)
%     data = FETCHVARIABLEDATA(__,Name,Value)
%     [data,flags] = FETCHVARIABLEDATA(__)
%
%   Description
%     data = FETCHVARIABLEDATA(dp,poolIdx,variableIdx) gathers data of all
%       poolIdx-variableIdx pairs.
%
%     data = FETCHVARIABLEDATA(__,Name,Value) specifies additional
%       properties using one or more Name,Value pair arguments.
%
%     [data,flags] = FETCHVARIABLEDATA(__) additionally returns the data
%       flags associated with the data.
%
%   Example(s)
%     data = FETCHVARIABLEDATA(dp,2,1)
%     data = FETCHVARIABLEDATA(dp,[5;3;6],[1;1;1])
%
%
%   Input Arguments
%     dp - data pool
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%     poolIdx - data pool index
%       numeric vector
%         A list of data pool indices corresponding to the variableIdx. Has
%         to have the same size as variableIdx.
%
%     variableIdx - variable index
%       numeric vector
%         A list of variable indices corresponding to the poolIdx. Has to
%         have the same size as poolIdx.
%
%
%   Output Arguments
%
%     data - returned data
%       2D matrix | cell
%         If poolIdx and variableIdx are scalar, the data is returned in
%         its original data type as matrix. If they are not scalar or
%         ForceCellOutput is set to true, each one is returned within a
%         cell.
%
%     flags - returned data flags
%       2D matrix | cell
%         If poolIdx and variableIdx are scalar, the data is returned as a
%         dataFlag matrix. If they are not scalar or ForceCellOutput is set
%         to true, each one is returned within a cell.
%
%
%   Name-Value Pair Arguments
%     ReturnRawData - return raw data
%       false (default) | true
%         Determines if data is returned without calibration functions
%         being applied.
%
%     ForceCellOutput - force cell output
%       true (default) | false
%         Determine if data should be kept in cells even if the returned
%         data is uniform.
%
%
%   See also DATAPOOL, FINDVARIABLE
%
%   Copyright 2020 David Clemens (dclemens@geomar.de)
%
    
    import DataKit.arrayhom

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
    [poolIdx,variableIdx] = arrayhom(poolIdx,variableIdx);
    nVariables  = numel(variableIdx);
    
    if returnRawData
        data = arrayfun(@(p,v) obj.DataRaw{p}(:,v),poolIdx,variableIdx,'un',0);
    else
        data = arrayfun(@(p,v) obj.Data{p}(:,v),poolIdx,variableIdx,'un',0);
    end
    origin  = arrayfun(@(p,v) obj.Info(p).VariableOrigin{v},poolIdx,variableIdx,'un',0);
    
    flags   = arrayfun(@(p,v) obj.Flag{p}(:,v),poolIdx,variableIdx,'un',0);
    
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
        flags   = flags{:};
    end
end