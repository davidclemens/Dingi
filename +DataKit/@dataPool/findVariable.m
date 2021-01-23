function [poolIdx,variableIdx] = findVariable(obj,varargin)
% findVariable  Find dataPool variables with specified property values
%   FINDVARIABLE Find dataPool variables with specified property values and
%   return their pool and variable index.
%
%   Syntax
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'P1Name',P1Value,...)
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'P1Name',P1Value,'-logicaloperator',...)
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'-regexp','P1Name','regexp',...)
%
%   Description
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'P1Name',P1Value,...) returns the
%     indices of the variables for dataPool obj whose property values match
%     those passed as param-value pairs to the findVariable command.
%
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'P1Name',P1Value,'-logicaloperator',...)
%     applies the logical operator to the property value matching. Possible
%     values for -logicaloperator are -and, -or, -xor, -not.
%
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'-regexp','P1Name','regexp',...)
%     matches variables using regular expressions as if the value of the
%     property P1Name is passed to REGEXP as:
%     regexp('P1Name', 'regexp').
%     findVariable returns the variable's indices if a match occurs.
%
%   Example(s)
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'Variable','Oxygen') returns the
%     indices of all variables named 'Oxygen'.
%
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'Variable','Oxygen','VariableMeasuringDevice.Type','BigoOptode')
%     returns the indices of all variables named 'Oxygen' that where measured by
%     measurement devices of type 'BigoOptode'.
%
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'-not','Variable','Oxygen','-regexp',VariableMeasuringDevice.Type','^Bigo.*')
%     returns the indices of all variables NOT named 'Oxygen' that where
%     measured by measurement devices that start with 'Bigo' (i.e. matching the
%     regular expression '^Bigo.*').
%
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'VariableType','Dependant','-and','-regexp',VariableMeasuringDevice.deviceDomain','^Chamber/d+')
%     returns the indices of all dependant variables that where measured in a
%     deviceDomain 'Chamber' (i.e. matching the regular expression
%     '^Chamber/d+').
%
%
%   Input Arguments
%     obj - dataPool instance
%       DataKit.dataPool
%         An DataKit.dataPool instance within which to find the variables.
%
%     PxName - xth property name
%       char
%         The xth property name of the name-value pairs against which PxValue is
%         matched.
%
%     PxValue - xth property value
%       ...
%         The xth property value of the name-value pairs which is matched
%         against the value of PxName.
%
%     -logicaloperator - logical operator
%       '-and' | '-or' | '-xor' | '-not'
%         Applies the logical operator to the property value matching between
%         which it is placed ('-and', '-or' & '-xor') or infront of which it is
%         placed ('-not').
%
%
%   Output Arguments
%     poolIdx - data pool index
%       numeric vector
%         Data pool index that identifies the matched variables together with
%         the variableIdx.
%
%     variableIdx - variable index
%       numeric vector
%         Variable index that identifies the matched variables together with
%         the poolIdx.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAPOOL, FETCHVARIABLEDATA
%
%   Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
%

    validOperators = {'-and','-or','-xor','-not','-regexp'};
    maskIsCompinationalOperator = [true(1,3),false(1,2)];

    propertyList    = obj.PropertyList;

    nInputs         = numel(varargin);
    maskIsOperator  = false(1,nInputs);
    maskIsName      = false(1,nInputs);
    maskIsValue     = false(1,nInputs);

    maskIsChar                  = cellfun(@ischar,varargin);
    maskIsOperator(maskIsChar)  = ~cellfun(@isempty,regexp(varargin(maskIsChar),'^-'));
    indIsNotOperator            = find(~maskIsOperator);
    indIsName                   = indIsNotOperator(1:2:end);
    maskIsName(indIsName)       = true;
    maskIsValue(indIsName + 1) 	= true;

    if ~all(maskIsChar(maskIsName))
        error('All property names must be char.')
    end
    if ~all(maskIsChar(maskIsOperator))
        error('All operators must be char.')
    end

    nNames  = sum(maskIsName);
    names   = varargin(maskIsName);
    names   = regexp(names,'\.','split')';
    values  = varargin(maskIsValue);
    indNameStart	= [1,indIsName(1:end - 1) + 2];
    indNameEnd      = indIsName + 1;

    indIsOperator   = find(maskIsOperator);

    operators               = cell(nNames,1);
    combinationalOperators  = cell(nNames,1);
    for nn = 1:nNames
        maskRange   = false(1,nInputs);
        maskRange(indNameStart(nn):indNameEnd(nn)) = true;
        operators{nn} = varargin(maskIsOperator & maskRange);

        % add -and operator if no other logical operator is found
        if nn > 1 && all(~ismember(validOperators(maskIsCompinationalOperator),operators{nn}))
            operators{nn} = cat(2,operators{nn},{'-and'});
        end
        combinationalOperators{nn} = operators{nn}(ismember(validOperators(maskIsCompinationalOperator),operators{nn}));
        if numel(combinationalOperators{nn}) > 1
            error('only 1 combinational logical operator is allowed per name-value pair.')
        elseif numel(combinationalOperators{nn}) == 1
            combinationalOperators{nn} = combinationalOperators{nn}{:};
        end
    end

    nObjValues  = numel(propertyList);
    objValues   = cell(1,nNames);
    bool        = false(nObjValues,nNames);
    for nn = 1:nNames
        objValues{nn} = getAllLevels(propertyList,names{nn});

        if ismember('-regexp',operators{nn})
            try
                % check if object is convertible to cellstr
                str = cellstr(cat(1,objValues{nn}{:}));
            catch ME
                switch ME.identifier
                    case 'MATLAB:catenate:dimensionMismatch'
                        % revert to original object
                        str = objValues{nn};
                    otherwise
                        rethrow(ME)
                end
            end
            bool(:,nn) = ~cellfun(@isempty,regexp(str,values{nn}));
        else
            switch class(objValues{nn}{1})
                case 'char'
                    bool(:,nn) = cellfun(@(a) strcmp(a,values{nn}),objValues{nn});
                otherwise
                    bool(:,nn) = cellfun(@(a) a == values{nn},objValues{nn});
            end
        end

        if ismember('-not',operators{nn})
            bool(:,nn)  = ~bool(:,nn);
        end
    end

    % now combine logical results if neccessary
    boolAll     = bool(:,1);
    if nNames > 1
        for nn = 2:nNames
            switch combinationalOperators{nn}
                case '-and'
                    boolAll = and(boolAll,bool(:,nn));
                case '-or'
                    boolAll = or(boolAll,bool(:,nn));
                case '-xor'
                    boolAll = xor(boolAll,bool(:,nn));
                otherwise
                    error('')
            end
        end
    end

    poolIdx     = cat(1,propertyList(boolAll).poolIdx);
    variableIdx = cat(1,propertyList(boolAll).variableIdx);
end

function values = getAllLevels(list,names)

    nLevels = numel(names);
    if nLevels > 1
        list = cat(1,list.(names{1}));
        values = getAllLevels(list,names(2:end));
    else
            values = {list.(names{end})}';
    end
end
