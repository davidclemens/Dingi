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
%     [poolIdx,variableIdx] = FINDVARIABLE(obj,'VariableType','Dependent','-and','-regexp',VariableMeasuringDevice.deviceDomain','^Chamber/d+')
%     returns the indices of all dependent variables that where measured in a
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
%   Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)
%

    validOperators = {'-and','-or','-xor','-not','-regexp'};
    maskIsCompinationalOperator = [true(1,3),false(1,2)];

    % Get all object properties
    propertyList    = obj.PropertyList;

    % Initialize variables
    nInputs         = numel(varargin);
    maskIsOperator  = false(1,nInputs);
    maskIsName      = false(1,nInputs);
    maskIsValue     = false(1,nInputs);

    % Characterize inputs
    maskIsChar                  = cellfun(@ischar,varargin); % Find character inputs in the inputs
    maskIsOperator(maskIsChar)  = cellfun(@(in) any(strcmp(in,validOperators)),varargin(maskIsChar)); % Find operators inputs in the inputs
    indIsNotOperator            = find(~maskIsOperator); % Find inputs that are not operators
    indIsName                   = indIsNotOperator(1:2:end); % Every second non-operator input should be a 'Name', of the name-value pairs followed by its corresponding 'Value'
    maskIsName(indIsName)       = true; % Find 'Names' of the name-value pairs
    maskIsValue(indIsName + 1) 	= true; % Find 'Values' of the name-value pairs

    % Throw errors if necessary
    if ~all(maskIsChar(maskIsName))
        error('Dingi:DataKit:dataPool:findVariable:invalidPropertyNameType',...
          'All property names must be char.')
    end
    if ~all(maskIsChar(maskIsOperator))
        error('Dingi:DataKit:dataPool:findVariable:invalidOperatorType',...
          'All operators must be char.')
    end

    % Extract names. Split at the dot ('.') character allowing for matching
    % lower levels in the poolInfo object (i.e.
    % 'VariableMeasuringDevice.SerialNumber').
    nNames  = sum(maskIsName);
    names   = varargin(maskIsName);
    names   = regexp(names,'\.','split')';
    % Extract values corresponding to names.
    values  = varargin(maskIsValue);
    % Get the range of the name-value pairs including any corresponding operators in the inputs.
    indNameStart	= [1,indIsName(1:end - 1) + 2];
    indNameEnd      = indIsName + 1;

    % Initialize variables
    operators               = cell(nNames,1);
    combinationalOperators  = cell(nNames,1);
	% Loop over all names to process any operators
    for nn = 1:nNames
        % Get the range for the current name-value pair as a logical mask.
        maskRange   = false(1,nInputs);
        maskRange(indNameStart(nn):indNameEnd(nn)) = true;
        
        % Get any operators for the current name-value pair.
        operators{nn} = varargin(maskIsOperator & maskRange);

        % Add '-and' operator if no other logical operator is found.
        if nn > 1 && all(~ismember(validOperators(maskIsCompinationalOperator),operators{nn}))
            operators{nn} = cat(2,operators{nn},{'-and'});
        end
        combinationalOperators{nn} = operators{nn}(ismember(validOperators(maskIsCompinationalOperator),operators{nn}));
        if numel(combinationalOperators{nn}) > 1
            error('Dingi:DataKit:dataPool:findVariable:invalidNumberOfCombinationalLogicalOperators',...
              'Only 1 combinational logical operator is allowed per name-value pair.')
        elseif numel(combinationalOperators{nn}) == 1
            combinationalOperators{nn} = combinationalOperators{nn}{:};
        end
    end
    
    nObjValues  = numel(propertyList);
    % Initialize Variables
    objValues   = cell(1,nNames);
    bool        = false(nObjValues,nNames);
	% Loop over all names.
    for nn = 1:nNames
        % Get the actual values corresponding to the current name.
        objValues{nn} = getAllLevels(propertyList,names{nn});

        % Process the actual values according to any operator provided.
        if ismember('-regexp',operators{nn})
            % Match using the regular expression
            
            % Try converting the actual values to cellstr
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
            
            if iscellstr(values{nn})
                tmp = false(numel(str),numel(values{nn}));
                for ii = 1:numel(values{nn})
                    tmp(:,ii) = ~cellfun(@isempty,regexp(str,values{nn}{ii}));
                end
            else
                tmp = ~cellfun(@isempty,regexp(str,values{nn}));
            end
            bool(:,nn)  = any(tmp,2);
        else
            % Switch on the class of the actual value
            switch class(objValues{nn}{1})
                case 'char'
                    tmp	= cellfun(@(a) strcmp(a,values{nn}),objValues{nn},'un',0);
                otherwise
                	tmp	= cellfun(@(a) a == values{nn},objValues{nn},'un',0);
            end
            tmp         = cat(1,tmp{:});
            bool(:,nn)  = any(tmp,2);
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
