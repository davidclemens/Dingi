function data = fetchData(obj,varargin)
% fetchData  Gathers data from a datapool object in various ways.
%   FETCHDATA returns the data within a datapool object by allowing to
%   specify what data is wanted and in what order and structure it should
%   be returned.
%
%   Syntax
%     data = FETCHDATA(dp)
%     data = FETCHDATA(dp,var)
%     data = FETCHDATA(dp,var,varType)
%     data = FETCHDATA(dp,var,varType,md)
%     data = FETCHDATA(dp,var,varType,md,mdType)
%     data = FETCHDATA(dp,var,varType,md,mdType,poolIdx)
%     data = FETCHDATA(dp,var,varType,md,mdType,poolIdx,varIdx)
%     data = FETCHDATA(__,Name,Value)
%
%   Description
%     data = FETCHDATA(dp) gathers data of all variables available in the
%       datapool instance dp and returns them in the data structure.
%
%     data = FETCHDATA(dp,var) gathers data of the specified variables var
%       available in the datapool instance dp and returns them in the data
%       structure.
%
%     data = FETCHDATA(dp,var,varType) as above, and additionally allows
%       for the variable type to be specified.
%
%     data = FETCHDATA(dp,var,varType,md) as above, and additionally allows
%       for the measuring device to be specified.
%
%     data = FETCHDATA(dp,var,varType,md,mdType) as above, and additionally
%       allows for the measuring device type to be specified.
%
%     data = FETCHDATA(dp,var,varType,md,mdType,poolIdx) as above, and
%       additionally allows for the data pool index to be specified.
%
%     data = FETCHDATA(dp,var,varType,md,mdType,poolIdx,varIdx) as above,
%       and additionally allows for the variable index to be specified.
%
%     Any optional argument can be ommited by setting it to [].
%     All optional arguments are combined by the logical and operation.
%
%     data = FETCHDATA(__,Name,Value) specifies additional properties using
%       one or more Name,Value pair arguments.
%
%   Example(s)
%     data = FETCHDATA(dp,'Oxygen')
%     data = FETCHDATA(dp,{'Oxygen','Temperature'})
%     data = FETCHDATA(dp,[2,15])
%     data = FETCHDATA(dp,DataKit.Metadata.variable)
%     data = FETCHDATA(dp,[],'Independent')
%     data = FETCHDATA(dp,[],[],GearKit.measuringDevice)
%     data = FETCHDATA(dp,[],[],[],'BigoOptode')
%     data = FETCHDATA(dp,[],[],[],[],[2,3])
%     data = FETCHDATA(dp,[],[],[],[],[2,3],[2,2])
%     data = FETCHDATA(dp,[],[],[],[],[],[3,4])
%
%
%   Input Arguments
%     dp - data pool
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%     var - requested variable(s)
%       [] (default) | char vector | cellstr | numeric vector |
%       DataKit.Metadata.variable
%         A list of requested variables. It can be specified by variable
%         name (char, cellstr), variable id (numeric) or as an instance of
%         the DataKit.Metadata.variable class.
%         If left empty (default), data of all variables available in the
%         data pool are returned.
%
%     varType - variable type
%       [] (default) | DataKit.Metadata.validators.validInfoVariableType
%         The variable type ('Dependent' or 'Independent').
%         If left empty (default), data of all variable types available in
%         the data pool are returned.
%
%     md - measuring device
%       [] (default) | GearKit.measuringDevice
%         If specified, only data captured by the measuring device md is
%         returned.
%         If left empty (default), data of all measuring devices available
%         in the data pool are returned.
%
%     mdType - measuring device type
%       [] (default) | GearKit.measuringDeviceType
%         If specified, only data captured by a measuring device of type
%         mdType is returned. Type
%         'GearKit.measuringDeviceType.listMembers' for a
%         list of all measuring device types.
%         If left empty (default), data of all measuring device types
%         available in the data pool are returned.
%
%     poolIdx - data pool index
%       [] (default) | numeric vector
%         If specified, only data from data pools at index poolIdx are
%         returned.
%         If left empty (default), data from all data pools available in
%         the data pool are returned.
%
%     varIdx - variable index
%       [] (default) | numeric vector
%         If specified, only data from variables at index varIdx are
%         returned.
%         If left empty (default), data from all variable indices available
%         in the data pool are returned.
%
%
%   Output Arguments
%
%     data - returned data
%       scalar struct
%         Scalar struct holding the data matching the requests. It has the
%         following fields:
%           - IndepData
%           - DepData
%           - IndepInfo
%           - DepInfo
%           - Flags
%
%         The structure of the 2 data fields is as follows, if the request
%         results in the return of N variables Var1 to VarN grouped into M
%         groups Group1 to GroupM and Var1 is found in data pools dp2 and
%         dp3 while VarN is found in dp5, dp6 and dp7.
%         If, for example, dp3 doesn't contain independent variable indepI,
%         it is filled with the appropriate empty value type.
%         Flags has the same structure as DepData and holds bitflag
%         instances with the flags that applied to the dependent data.
%
%         data.DepData:
%
%                MxN cell
%                  Var1  ,..., VarN
%                ┌                   ┐
%                │┌─────┐     ┌─────┐│
%         Group1 ││slot1│     │slot1││
%                ││dp2  │     │dp5  ││
%                ││var1 │     │varN ││
%                ││data │     │data ││
%                ││  ⁝  │     │  ⁝  ││
%                ││     │     │     ││
%                ││     │     ├─────┤│
%                ││     │  …  │slot2││
%                │├─────┤     │dp6  ││
%                ││slot2│     │varN ││
%                ││dp3  │     │data ││
%                ││var1 │     │  ⁝  ││
%                ││data │     │     ││
%                ││  ⁝  │     └─────┘│
%                ││     │            │
%                │└─────┘            │
%                │   ⋮     ⋱     ⋮   │
%                │┌─────┐     ┌─────┐│
%         GroupM ││slot1│     │slot1││
%                ││dp2  │     │dp5  ││
%                ││var1 │     │varN ││
%                ││data │     │data ││
%                ││  ⁝  │     │  ⁝  ││
%                ││     │     │     ││
%                ││     │     ├─────┤│
%                ││     │  …  │slot2││
%                │└─────┘     │dp6  ││
%                │            │varN ││
%                │            │data ││
%                │            │  ⁝  ││
%                │            │     ││
%                │            │     ││
%                │            ├─────┤│
%                │            │slot3││
%                │            │dp7  ││
%                │            │varN ││
%                │            │data ││
%                │            │  ⁝  ││
%                │            │     ││
%                │            │     ││
%                │            │     ││
%                │            │     ││
%                │            │     ││
%                │            └─────┘│
%                └                   ┘
%
%
%         data.IndepData:
%
%                MxN cell
%                  Var1                ,..., VarN
%                ┌                                               ┐
%                │1xI cell                  1xI cell             │
%                │┌───────┬ ─ ┬───────┐     ┌───────┬ ─ ┬───────┐│
%         Group1 ││dp2    │   │dp2    │     │dp5    │   │dp5    ││
%                ││var1   │   │var1   │     │varN   │   │varN   ││
%                ││indep1 │   │indepI │     │indep1 │   │indepI ││
%                ││data   │   │data   │     │data   │   │data   ││
%                ││   ⁝   │   │   ⁝   │     │   ⁝   │   │   ⁝   ││
%                ││       │   │       │     ├───────┤ … ├───────┤│
%                ││       │ … │       │  …  │dp6    │   │dp6    ││
%                │├───────┤   ├───────┤     │varN   │   │varN   ││
%                ││dp3    │   │dp3    │     │indep1 │   │indepI ││
%                ││var1   │   │var1   │     │data   │   │data   ││
%                ││indep1 │   │indepI │     │   ⁝   │   │   ⁝   ││
%                ││data   │   │data   │     └───────┴ ─ ┴───────┘│
%                ││   ⁝   │   │   ⁝   │                          │
%                │└───────┴ ─ ┴───────┘                          │
%                │          ⋮            ⋱            ⋮          │
%                │┌───────┬ ─ ┬───────┐     ┌───────┬ ─ ┬───────┐│
%         GroupM ││dp2    │   │dp2    │     │dp5    │   │dp5    ││
%                ││var1   │   │var1   │     │varN   │   │varN   ││
%                ││indep1 │   │indepI │     │indep1 │   │indepI ││
%                ││data   │ … │data   │     │data   │   │data   ││
%                ││   ⁝   │   │   ⁝   │     │   ⁝   │   │   ⁝   ││
%                ││       │   │       │     ├───────┤ … ├───────┤│
%                ││       │   │       │     │dp6    │   │dp6    ││
%                │└───────┴ ─ ┴───────┘     │varN   │   │varN   ││
%                │                          │indep1 │   │indepI ││
%                │                          │data   │   │data   ││
%                │                       …  │   ⁝   │   │   ⁝   ││
%                │                          │       │   │       ││
%                │                          ├───────┤ … ├───────┤│
%                │                          │dp7    │   │dp7    ││
%                │                          │varN   │   │varN   ││
%                │                          │indep1 │   │indepI ││
%                │                          │data   │   │data   ││
%                │                          │   ⁝   │   │   ⁝   ││
%                │                          │       │   │       ││
%                │                          │       │   │       ││
%                │                          │       │   │       ││
%                │                          │       │   │       ││
%                │                          └───────┴ ─ ┴───────┘│
%                └                                               ┘
%
%
%   Name-Value Pair Arguments
%     ReturnRawData - return raw data
%       false (default) | true
%         Determines if data is returned without calibration functions
%         being applied.
%
%     GroupBy - set grouping type
%       '' (default) | 'Variable' | 'MeasuringDevice' | ...
%         Sets how the returned data is grouped.
%
%     ForceCellOutput - force cell output
%       false (default) | true
%         Determine if data should be kept in cells even if the returned
%         data is uniform.
%
%
%   See also DATAPOOL
%
%   Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)
%

    [...
        obj,...
        variable,...
        variableType,...
      	measuringDevice,...
      	measuringDeviceType,...
        poolIdx,...
        varIdx,...
        sort,...
        returnRawData,...
        forceReturnIndependentVariable,...
        relativeTime,...
        groupBy,...
        forceCellOutput...
    ] = parseInputs(obj,varargin{:});


    objIndex    = obj.Index;

    % test all criteria against the data pool index. They are combined by
    % the logical AND operation.
    maskIndex   = true(size(objIndex,1),1);
    if ~isempty(variable)
        if isa(variable,'DataKit.Metadata.variable')
            % ok
        elseif isnumeric(variable)
            variable    = DataKit.Metadata.variable.fromProperty('Id',variable);
        else
            variable    = DataKit.Metadata.variable(variable);
        end
        variableIsRequested     = ismember(objIndex{:,'Variable'},variable);
        variableIsInDataPool    = ismember(variable,objIndex{:,'Variable'});
        maskIndex   = maskIndex & ...
                        variableIsRequested;
    else
        variableIsInDataPool = [];
    end
    if ~isempty(variableType)
        maskIndex   = maskIndex & ...
                        any(objIndex{:,'VariableType'} == variableType,2);
    end
    if ~isempty(measuringDevice)
        maskIndex   = maskIndex & ...
                        any(objIndex{:,'MeasuringDevice'} == measuringDevice,2);
    end
    if ~isempty(measuringDeviceType)
        maskIndex   = maskIndex & ...
                        any(cat(1,objIndex{:,'MeasuringDevice'}.Type) == measuringDeviceType,2);
    end
    if ~isempty(poolIdx)
        maskIndex   = maskIndex & ...
                        any(objIndex{:,'DataPool'} == poolIdx',2);
    end
    if ~isempty(varIdx)
        maskIndex   = maskIndex & ...
                        any(objIndex{:,'VariableIndex'} == varIdx',2);
    end
    maskIndex       = maskIndex & ...
                        objIndex{:,'VariableType'} == 'Dependent';
    nIndexMatches   = sum(maskIndex);


 	data            = struct();
    data.IndepData	= {};
   	data.DepData    = {};
   	data.Flags      = {};
    data.IndepInfo  = struct(...
                        'Variable',             {{DataKit.Metadata.variable.empty}},...
                        'PoolIdx',              [],...
                        'VariableIdx',          []);
    data.DepInfo    = struct(...
                        'Variable',             DataKit.Metadata.variable.empty,...
                        'MeasuringDevice',      GearKit.measuringDevice.empty,...
                        'PoolIdx',              [],...
                        'VariableIdx',          []);


    if any(~variableIsInDataPool)
        error('Dingi:DataKit:dataPool:fetchData:requestedVariableIsUnavailable',...
            '\nTODO: The requested variable ''%s'' is not a member of the data pool.\nAvailable variables are:\n\t%s\n',char(variable(find(~variableIsInDataPool,1))),strjoin(unique(cellstr(objIndex{:,'Variable'})),', '))
    end
    if nIndexMatches == 0
        warning('Dingi:DataKit:dataPool:fetchData:noDataForRequestedInputsAvailable',...
            'No data matches the requested combination of inputs.')
        return
    end
    if isempty(variable)
        [~,uIdx,~]  = unique(objIndex{maskIndex,'Variable'});
        variable    = objIndex{maskIndex,'Variable'};
        variable    = variable(uIdx);
    end

    nVariable   = numel(variable);
    [~,uVariableIdx]    = ismember(objIndex{maskIndex,'Variable'},variable);

    [uMeasuringDevices,~,uMeasuringDevicesIdx]	= unique(objIndex{maskIndex,'MeasuringDevice'});
    nMeasuringDevices   = numel(uMeasuringDevices);

    % indices of index matches into the data pool
    dp      = objIndex{maskIndex,'DataPool'}; % data pool index
    dv      = objIndex{maskIndex,'VariableIndex'}; % dependent variable index
    iv      = objIndex{maskIndex,'IndependentVariableIndex'}; % independent variable(s) index

    % fetch data
	[ddata,flags]	= obj.fetchVariableData(dp,dv,...
                        'ReturnRawData',    returnRawData);
    idata 	= cellfun(@(dp,iv) obj.fetchVariableData(dp,iv,'ReturnRawData',returnRawData),num2cell(dp),iv,'un',0);
    % fetch metadata
    dinfo   = arrayfun(@(dp,dv) obj.Info(dp).selectVariable(dv),dp,dv);
    iinfo   = cellfun(@(dp,iv) obj.Info(dp).selectVariable(iv),num2cell(dp),iv);


    % setup grouping parameters
	switch groupBy
        case ''
            groupIdx    = ones(nIndexMatches,1);
            nGroups     = 1;
        case 'MeasuringDevice'
            groupIdx    = uMeasuringDevicesIdx;
            nGroups     = nMeasuringDevices;
        case 'Variable'
            groupIdx    = (1:nIndexMatches)';
            nGroups     = nIndexMatches;
	end

    % Handle multiple unique independent variables:
    % 1. Find the unique independent variables in all the data that has
    %    been fetched (idata).
    uIndepVariables           	= cellfun(@(dp,v) obj.Info(dp).Variable(v),num2cell(dp),iv,'un',0); % all independent variables found in idata (with repetition)
    [uIndepVariables,uIdx1uIndepVariables,uIdx2uIndepVariables]  = unique(cat(2,uIndepVariables{:}),'stable'); % all independent variables found in idata (without repetition)
    nUIndepVariables    = numel(uIndepVariables);

    % 2. Find the return datatype for the uIndepVariables. This allows the
    %    initialization of the output cell iData.
    uIndepVariablesDataType   	= cellfun(@(dp,v) obj.Info(dp).VariableReturnDataType(v),num2cell(dp),iv,'un',0);
    uIndepVariablesDataType    	= cat(2,uIndepVariablesDataType{:});
    uIndepVariablesDataType   	= uIndepVariablesDataType(uIdx1uIndepVariables);

    % 3. Construct an index back into idata but of the shape of all
    %    independent variables in idata vertically concatenated.
    uIndepVariablesMatchIndex	= arrayfun(@(n) repmat(n,1,numel(iv{n})),(1:nIndexMatches)','un',0);
    uIndepVariablesMatchIndex	= reshape(cat(2,uIndepVariablesMatchIndex{:}),[],1);

    % Determine slot sizes and locations
    nData    	= cellfun(@numel,ddata); % length of each variable in ddata
    nDataOut    = accumarray([groupIdx,uVariableIdx],nData,[nGroups,nVariable]); % total length of the output cell for each (var,gr) pair.
    % As the order of the accumulated vectors that are passed into the
    % accumulation function doesn't appear to be stable, it is solved the
    % following way.
    % idxDataOut  = accumarray([groupIdx,uVariableIdx],nData,[nGroups,nVariable],@(x) {cumsum(x)});
    idxDataOutIdx   = sub2ind([nGroups,nVariable],groupIdx,uVariableIdx);
    idxDataOut      = reshape(arrayfun(@(i) cumsum(nData(idxDataOutIdx == i)),1:nGroups*nVariable,'un',0),[nGroups,nVariable]); % end indices of the all slots in those cells

    % initialize data outputs
    iData   = arrayfun(@(n) DataKit.getNotANumberValueForClass(cellstr(uIndepVariablesDataType),[n,1]),nDataOut,'un',0);
    dData   = arrayfun(@(n) NaN(n,1),nDataOut,'un',0);
    Flags   = arrayfun(@(n) DataKit.bitflag(obj.Flag{1}.EnumerationClassName,n,1),nDataOut,'un',0);

    % populate data outputs
  	for var = 1:nVariable
        % loop over requested variables
        maskVar     = uVariableIdx == var;

        for gr = 1:nGroups
            % loop over groups resulting from the 'GroupBy' request
            idxData         = find(maskVar & groupIdx == gr); % index into ddata/idata for the current (var,gr) pair.
            idxIVar         = uIdx2uIndepVariables(any(uIndepVariablesMatchIndex == idxData',2));

            [~,~,uIdx2uSlots] = unique(uIndepVariablesMatchIndex(any(uIndepVariablesMatchIndex == idxData',2)),'stable');
            dData{gr,var}   = cat(1,ddata{idxData}); % the dependent data that belongs to variable 'var' and group 'gr' only
            Flags{gr,var}   = cat(1,flags{idxData}); % the dependent data that belongs to variable 'var' and group 'gr' only
            tmpIData        = cat(1,idata{idxData}); % the independent data that belongs to variable 'var' and group 'gr' only
            slotStart       = [0;idxDataOut{gr,var}(1:end - 1)] + 1; % start indices for that data in the output slot
            slotEnd         = idxDataOut{gr,var}; % end indices for that data in the output slot

            for ivar = 1:numel(tmpIData)
                % loop over all input independent variables
                slotRange   = (slotStart(uIdx2uSlots(ivar)):slotEnd(uIdx2uSlots(ivar)))';
                iData{gr,var}{idxIVar(ivar)}(slotRange) = tmpIData{ivar}; % write data to appropriate slot
            end
        end
    end

    % assign metadata
    data.IndepInfo.Variable         = cell(nGroups,nVariable);
    data.IndepInfo.PoolIdx          = cell(nGroups,nVariable);
    data.IndepInfo.VariableIdx      = cell(nGroups,nVariable);
    data.DepInfo.Variable           = repmat(DataKit.Metadata.variable.undefined,nGroups,nVariable);
    tmpInfoDepVar                   = repmat(variable',nGroups,1);
    data.DepInfo.PoolIdx            = NaN(nGroups,nVariable);
    data.DepInfo.VariableIdx        = NaN(nGroups,nVariable);
    data.DepInfo.MeasuringDevice	= repmat(GearKit.measuringDevice(),nGroups,nVariable);

    data.IndepInfo.Variable(idxDataOutIdx)          = repmat({uIndepVariables},numel(idxDataOutIdx),1);
    data.DepInfo.Variable(idxDataOutIdx)            = tmpInfoDepVar(idxDataOutIdx);

	switch groupBy
        case ''
        case 'MeasuringDevice'
            data.DepInfo.MeasuringDevice(idxDataOutIdx)	= cat(1,dinfo.VariableMeasuringDevice);
        case 'Variable'
            data.DepInfo.PoolIdx(idxDataOutIdx)         = dp;
            data.DepInfo.VariableIdx(idxDataOutIdx)     = dv;
            data.DepInfo.MeasuringDevice(idxDataOutIdx)	= cat(1,dinfo.VariableMeasuringDevice);
            data.IndepInfo.PoolIdx(idxDataOutIdx)    	= cellfun(@(dp,iv) repmat(dp,1,numel(iv)),num2cell(dp),iv,'un',0);
            data.IndepInfo.VariableIdx(idxDataOutIdx)	= iv;
	end

    if nVariable <= 1 && ~forceCellOutput
        data.IndepData	= iData{1};
        data.DepData    = dData{1};
        data.Flags      = Flags{1};
    else
        data.IndepData	= iData;
        data.DepData    = dData;
        data.Flags      = Flags;
    end
end

function varargout = parseInputs(obj,varargin)

    p = inputParser;

    defaultVariable             = [];
    defaultVariableType        	= [];
    defaultMeasuringDevice      = [];
    defaultMeasuringDeviceType	= [];
    defaultPoolIdx              = [];
    defualtVarIdx               = [];

    defaultSort                             = false;
    defaultReturnRawData                    = false;
    defaultForceReturnIndependentVariable	= true;
    defaultRelativeTime                     = '';
    defaultGroupBy                          = 'Variable';
    defaultForceCellOutput                  = false;

    validRelativeTime   = {'','milliseconds','seconds','minutes','hours','days','years'};
    validGropuBy        = {'','Variable','MeasuringDevice'}; % 'MeasuringDeviceType','DataPool','VariableType'

    checkVariableType         	= @(x) (isempty(x) && isa(x,'double')) || GearKit.gearType.validate('GearType',x);
    checkMeasuringDevice        = @(x) (isempty(x) && isa(x,'double')) || isa(x,'GearKit.measuringDevice');
    checkMeasuringDeviceType    = @(x) (isempty(x) && isa(x,'double')) || ((ischar(x) || iscellstr(x)) && ismember(x,GearKit.measuringDeviceType.listMembers));
    checkPoolIdx                = @(x) (isempty(x) && isa(x,'double')) || (isvector(x) && isnumeric(x) && all(x <= obj.PoolCount));
    checkVarIdx                 = @(x) (isempty(x) && isa(x,'double')) || (isvector(x) && isnumeric(x) && all(x <= max(obj.Index{:,'VariableIndex'})));

    isScalarLogical    	= @(x) isscalar(x) && islogical(x);
    checkRelativeTime   = @(x) ischar(validatestring(x,validRelativeTime));
    checkGroupBy        = @(x) ischar(validatestring(x,validGropuBy));

    addRequired(p,'obj')
    addOptional(p,'variable',defaultVariable,@checkVariable)
    addOptional(p,'variableType',defaultVariableType,checkVariableType)
    addOptional(p,'measuringDevice',defaultMeasuringDevice,checkMeasuringDevice)
    addOptional(p,'measuringDeviceType',defaultMeasuringDeviceType,checkMeasuringDeviceType)
    addOptional(p,'poolIdx',defaultPoolIdx,checkPoolIdx)
    addOptional(p,'varIdx',defualtVarIdx,checkVarIdx)
    addParameter(p,'Sort',defaultSort,isScalarLogical)
    addParameter(p,'ReturnRawData',defaultReturnRawData,isScalarLogical)
    addParameter(p,'ForceReturnIndependentVariable',defaultForceReturnIndependentVariable,isScalarLogical)
    addParameter(p,'RelativeTime',defaultRelativeTime,checkRelativeTime)
    addParameter(p,'GroupBy',defaultGroupBy,checkGroupBy)
    addParameter(p,'ForceCellOutput',defaultForceCellOutput,isScalarLogical)

    parse(p,obj,varargin{:})

    obj                 = p.Results.obj;
    variable            = p.Results.variable;
    variableType     	= p.Results.variableType;
    measuringDevice 	= p.Results.measuringDevice;
    measuringDeviceType	= p.Results.measuringDeviceType;
    poolIdx             = p.Results.poolIdx;
    varIdx              = p.Results.varIdx;
    sort                            = p.Results.Sort;
    returnRawData                   = p.Results.ReturnRawData;
    forceReturnIndependentVariable  = p.Results.ForceReturnIndependentVariable;
    relativeTime                    = validatestring(p.Results.RelativeTime,validRelativeTime);
    groupBy                         = validatestring(p.Results.GroupBy,validGropuBy);
    forceCellOutput               	= p.Results.ForceCellOutput;

    poolIdx     = poolIdx(:);
    varIdx      = varIdx(:);

    varargout   = {...
                    obj,...
                    variable,...
                    variableType,...
                    measuringDevice,...
                    measuringDeviceType,...
                    poolIdx,...
                    varIdx,...
                    sort,...
                    returnRawData,...
                    forceReturnIndependentVariable,...
                    relativeTime,...
                    groupBy,...
                    forceCellOutput...
                  };
    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Dingi:DataKit:dataPool:fetchData:parseInputs:invalidNumberOfOutputs',...
          'Parsed variable number mismatches the output.')
	end
end

function bool = checkVariable(x)
    validVariable   = DataKit.Metadata.variable.listMembers;
    validVariableId = DataKit.Metadata.variable.listMembersInfo.Id;
    if isa(x,'DataKit.Metadata.variable')
        bool = true;
    elseif iscellstr(x)
        bool = all(cellfun(@(y) any(validatestring(y,validVariable)),x));
    elseif ischar(x)
        if size(x,1) == 1
            bool = any(validatestring(x,validVariable));
        else
            error('Dingi:DataKit:dataPool:fetchData:checkVariable:invalidCharShape',...
                'If variable is provided as a char, it has to be a vector of shape 1xn.\nIt was %s instead.\n',strjoin(cellstr(num2str(size(x)','%u')),' x '))
        end
    elseif isnumeric(x)
        if all(ismember(x,validVariableId))
            bool = true;
        else
         	error('Dingi:DataKit:dataPool:fetchData:checkVariable:invalidVariableId',...
                '''%u'' is an invalid variable id. Valid id''s are:\n\t%s\nIt was %u instead.\n',strjoin(regexprep(cellstr(num2str(validVariableId)),'\s+',''),', '),x(find(~ismember(x,validVariableId),1)))
        end
    else
        error('Dingi:DataKit:dataPool:fetchData:checkVariable:invalidType',...
            'Expected input ''variable'' to be one of these types:\n\tchar, cellstr, numeric\nIt was %s instead.\n',class(x))
    end
end
