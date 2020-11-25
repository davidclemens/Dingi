function data = fetchData(obj,varargin)
% FETCHDATA gathers data from a datapool object in various ways.
%
% Syntax
%   data = FETCHDATA(dp)
%   data = FETCHDATA(dp,var)
%   data = FETCHDATA(dp,var,varType)
%   data = FETCHDATA(dp,var,varType,md)
%   data = FETCHDATA(dp,var,varType,md,mdType)
%   data = FETCHDATA(dp,var,varType,md,mdType,poolIdx)
%   data = FETCHDATA(dp,var,varType,md,mdType,poolIdx,varIdx)
%   data = FETCHDATA(__,Name,Value)
%
% Description
%   data = FETCHDATA(dp) gathers data of all variables available in the
%       datapool instance dp and returns them in the data structure.
%
%   data = FETCHDATA(dp,var) gathers data of the specified variables var
%       available in the datapool instance dp and returns them in the data
%       structure.
%
%   data = FETCHDATA(dp,var,varType) as above, and additionally allows for
%       the variable type to be specified.
%
%   data = FETCHDATA(dp,var,varType,md) as above, and additionally allows
%       for the measuring device to be specified.
%
%   data = FETCHDATA(dp,var,varType,md,mdType) as above, and additionally
%       allows for the measuring device type to be specified.
%
%   data = FETCHDATA(dp,var,varType,md,mdType,poolIdx) as above, and
%       additionally allows for the data pool index to be specified.
%
%   data = FETCHDATA(dp,var,varType,md,mdType,poolIdx,varIdx) as above,
%       and additionally allows for the variable index to be specified.
%
%   Any optional argument can be ommited by setting it to [].
%   All optional arguments are combined by the logical and operation.
%
%   data = FETCHDATA(__,Name,Value) specifies additional properties using
%       one or more Name,Value pair arguments.
%
% Example(s)
%   data = FETCHDATA(dp,'Oxygen')
%   data = FETCHDATA(dp,{'Oxygen','Temperature'})
%   data = FETCHDATA(dp,[2,15])
%   data = FETCHDATA(dp,DataKit.Metadata.variable)
%   data = FETCHDATA(dp,[],'Independant')
%   data = FETCHDATA(dp,[],[],GearKit.measuringDevice)
%   data = FETCHDATA(dp,[],[],[],'BigoOptode')
%   data = FETCHDATA(dp,[],[],[],[],[2,3])
%   data = FETCHDATA(dp,[],[],[],[],[2,3],[2,2])
%   data = FETCHDATA(dp,[],[],[],[],[],[3,4])
%
%
% Input Arguments
%   dp - data pool
%       DataKit.dataPool
%           An instance of the DataKit.dataPool class.
%
%   var - requested variable(s)
%       [] (default) | char vector | cellstr | numeric vector |
%       DataKit.Metadata.variable
%           A list of requested variables. It can be specified by variable
%           name (char, cellstr), variable id (numeric) or as an instance
%           of the DataKit.Metadata.variable class.
%           If left empty (default), data of all variables available in the
%           data pool are returned.
%
%   varType - variable type
%       [] (default) | DataKit.Metadata.validators.validInfoVariableType
%           The variable type ('Dependant' or 'Independant').
%           If left empty (default), data of all variable types available
%           in the data pool are returned.
%
%   md - measuring device
%       [] (default) | GearKit.measuringDevice
%           If specified, only data captured by the measuring device md is
%           returned.
%           If left empty (default), data of all measuring devices
%           available in the data pool are returned.
%
%   mdType - measuring device type
%       [] (default) | GearKit.measuringDeviceType
%           If specified, only data captured by a measuring device of type
%           mdType is returned. Type
%           'GearKit.measuringDeviceType.listAllMeasuringDeviceType' for a
%           list of all measuring device types.
%           If left empty (default), data of all measuring device types
%           available in the data pool are returned.
%
%   poolIdx - data pool index
%       [] (default) | numeric vector
%           If specified, only data from data pools at index poolIdx are
%           returned.
%           If left empty (default), data from all data pools available in
%           the data pool are returned.
%
%   varIdx - variable index
%       [] (default) | numeric vector
%           If specified, only data from variables at index varIdx are
%           returned.
%           If left empty (default), data from all variable indices
%           available in the data pool are returned.
%
%
% Output Arguments
%
%   data - returned data
%       scalar struct
%           Scalar struct holding the data matching the requests. It has
%           the following fields:
%               - IndepData
%               - DepData
%               - IndepInfo
%               - DepInfo
%
%           The structure of the 2 data fields is as follows. If the
%           request results in the return of variables Var1 to VarN and
%           Var1 is found in data pool dp2 and dp3 while VarN is found in
%           dp5 and dp6.
%           If, for example, dp3 doesn't contain independant variable
%           indepI, it is filled with the appropriate empty value type.
%
%           data.DepData:
%
%           1xN cell
%             Var1  ,..., VarN
%           ┌                   ┐
%           │┌─────┐     ┌─────┐│
%           ││dp2  │     │dp5  ││
%           ││var1 │     │varN ││
%           ││data │     │data ││
%           ││  :  │     │  :  ││
%           ││  :  │     │  :  ││
%           ││  :  │     ├─────┤│
%           ││  :  │ ... │dp6  ││
%           │├─────┤     │varN ││
%           ││dp3  │     │data ││
%           ││var1 │     │  :  ││
%           ││data │     │  :  ││
%           ││  :  │     └─────┘│
%           ││  :  │            │
%           │└─────┘,   ,       │
%           └                   ┘
%
%
%           data.IndepData:
%
%           1xN cell
%             Var1                ,..., VarN
%           ┌                                               ┐
%           │1xI cell                  1xI cell             │
%           │┌───────┬ ─ ┬───────┐     ┌───────┬ ─ ┬───────┐│
%           ││dp2    │   │dp2    │     │dp5    │   │dp5    ││
%           ││var1   │   │var1   │     │varN   │   │varN   ││
%           ││indep1 │   │indepI │     │indep1 │   │indepI ││
%           ││data   │   │data   │     │data   │   │data   ││
%           ││   :   │   │   :   │     │   :   │   │   :   ││
%           ││   :   │   │   :   │     ├───────┤...├───────┤│
%           ││   :   │...│   :   │ ... │dp6    │   │dp6    ││
%           │├───────┤   ├───────┤     │varN   │   │varN   ││
%           ││dp3    │   │dp3    │     │indep1 │   │indepI ││
%           ││var1   │   │var1   │     │data   │   │data   ││
%           ││indep1 │   │indepI │     │   :   │   │   :   ││
%           ││data   │   │data   │     └───────┴ ─ ┴───────┘│
%           ││   :   │   │   :   │                          │
%           │└───────┴ ─ ┴───────┘,   ,                     │
%           └                                               ┘
%
%
% Name-Value Pair Arguments
%   ReturnRawData - return raw data
%       false (default) | true
%           Determines if data is returned without calibration functions
%           being applied.
%   GroupBy - set grouping type
%       '' (default) | 'Variable' | 'MeasuringDevice' | ...
%           Sets how the returned data is grouped.
%   ForceCellOutput - force cell output
%       false (default) | true
%           Determine if data should be kept in cells even if the returned
%           data is uniform.
%
%
% See also
%
% Copyright 2020 David Clemens (dclemens@geomar.de)
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
        forceReturnIndependantVariable,...
        relativeTime,...
        groupBy,...
        forceCellOutput...
    ] = parseInputs(obj,varargin{:});



    maskIndex   = true(size(obj.Index,1),1);
    if ~isempty(variable)
        if isa(variable,'DataKit.Metadata.variable')
            % ok
        elseif isnumeric(variable)
            variable    = DataKit.Metadata.variable.id2variable(variable);
        else
            variable    = DataKit.Metadata.variable.str2variable(variable);
        end
        variableIsRequested     = ismember(obj.Index{:,'Variable'},variable2str(variable));
        variableIsInDataPool    = ismember(variable2str(variable),obj.Index{:,'Variable'});
        maskIndex   = maskIndex & ...
                        variableIsRequested;
    else
        variableIsInDataPool = [];
    end
    if ~isempty(variableType)
        maskIndex   = maskIndex & ...
                        any(obj.Index{:,'VariableType'} == variableType,2);
    end
    if ~isempty(measuringDevice)
        maskIndex   = maskIndex & ...
                        any(obj.Index{:,'MeasuringDevice'} == measuringDevice,2);
    end
    if ~isempty(measuringDeviceType)
        maskIndex   = maskIndex & ...
                        any(cat(1,obj.Index{:,'MeasuringDevice'}.Type) == measuringDeviceType,2);
    end
    if ~isempty(poolIdx)
        maskIndex   = maskIndex & ...
                        any(obj.Index{:,'DataPool'} == poolIdx',2);
    end
    if ~isempty(varIdx)
        maskIndex   = maskIndex & ...
                        any(obj.Index{:,'VariableIndex'} == varIdx',2);
    end
    maskIndex       = maskIndex & ...
                        obj.Index{:,'VariableType'} == 'Dependant';
    idxIndex        = find(maskIndex);
    nIndexMatches   = numel(idxIndex);

    
 	data            = struct();
    data.IndepData	= {};
   	data.DepData    = {};
    data.IndepInfo  = struct(...
                        'Variable',             DataKit.Metadata.variable.empty,...
                        'MeasurmentDevice',     GearKit.measuringDevice.empty);
    data.DepInfo    = struct(...
                        'Variable',             DataKit.Metadata.variable.empty,...
                        'MeasurmentDevice',     GearKit.measuringDevice.empty);
    
    
    if nIndexMatches== 0
        error('DataKit:dataPool:fetchData:noRequestedVariableIsAvailable',...
            'TODO: no data to return scenario')
    end
    if any(~variableIsInDataPool)
        warning('DataKit:dataPool:fetchData:requestedVariableIsUnavailable',...
            '\nTODO: The requested variable ''%s'' is not a member of the data pool.\nAvailable variables are:\n\t%s\n',char(variable(find(~variableIsInDataPool,1))),strjoin(unique(variable2str(obj.Index{:,'Variable'})),', '))
        return
    end

    if isempty(variable)
        [~,uIdx,~]  = unique(variable2str(obj.Index{maskIndex,'Variable'}));
        variable    = obj.Index{maskIndex,'Variable'};
        variable    = variable(uIdx);
    end

    nVariable   = numel(variable);
    [~,uVariableIdx]    = ismember(variable2str(obj.Index{idxIndex,'Variable'}),variable2str(variable));

    [uMeasuringDevices,~,uMeasuringDevicesIdx]	= unique(obj.Index{idxIndex,'MeasuringDevice'});
    nMeasuringDevices   = numel(uMeasuringDevices);

    dp      = obj.Index{idxIndex,'DataPool'};
    dv      = obj.Index{idxIndex,'VariableIndex'};
    iv      = obj.Index{idxIndex,'IndependantVariableIndex'};
	ddata 	= obj.fetchVariableData(dp,dv,...
                'ReturnRawData',    returnRawData);
    idata 	= cellfun(@(dp,iv) obj.fetchVariableData(dp,iv,'ReturnRawData',returnRawData),num2cell(dp),iv,'un',0);
    
    
    uIVar               = cellfun(@(dp,v) obj.Info(dp).Variable(v),num2cell(dp),iv,'un',0);
    uIVarDp             = cellfun(@(dp,v) repmat(dp,1,numel(v)),num2cell(dp),iv,'un',0);
    uIVarDp             = reshape(cat(2,uIVarDp{:}),[],1);
    [uIVar,uIdx1IVar,uIdx2IVar]  = unique(variable2str(cat(2,uIVar{:})),'stable');
    uIVarDataType       = cellfun(@(dp,v) obj.Info(dp).VariableReturnDataType(v),num2cell(dp),iv,'un',0);
    uIVarDataType       = cat(2,uIVarDataType{:});
    uIVarDataType       = uIVarDataType(uIdx1IVar);
    
    nData               = cellfun(@numel,ddata);
    
	switch groupBy
         case {'','Variable'}
            groupIdx    = ones(nIndexMatches,1);
            nGroups     = 1;
        case 'MeasuringDevice'
            groupIdx    = uMeasuringDevicesIdx;
            nGroups     = nMeasuringDevices;
    end
    nData2      = accumarray([groupIdx,uVariableIdx],nData,[nGroups,nVariable]);
    
    idxData2    = accumarray([groupIdx,uVariableIdx],nData,[nGroups,nVariable],@(x) {cumsum(x)});
    % initialize data outputs
    iData   = arrayfun(@(n) DataKit.getNotANumberValueForClass(cellstr(uIVarDataType),[n,1]),nData2,'un',0);
    dData   = arrayfun(@(n) NaN(n,1),nData2,'un',0);
    
    for gr = 1:nGroups
        for var = 1:nVariable
            maskVar     = uVariableIdx == var;
            startIdx    = [0;idxData2{gr,var}(1:end - 1)] + 1;
            endIdx      = idxData2{gr,var};
            tmpDVar2    = ddata(maskVar);
            for ii = 1:numel(tmpDVar2)
                dData{gr,var}(startIdx(ii):endIdx(ii),1)    = tmpDVar2{ii};
            end
            for ivar = 1:numel(uIVar)
                tmpIVar2   	= cat(1,idata{maskVar});
                
                maskIVar    = find(uIdx2IVar == ivar);
                
                for ii = 1:numel(maskIVar)
                    try
                    if uIdx2IVar(maskIVar(ii)) == ii
                        iData{gr,var}{ivar}(startIdx(ii):endIdx(ii))   = tmpIVar2{uIdx2IVar(maskIVar(ii))};
                    end
                    catch
                        
                    end
                end
            end
        end
    end

    
    dinfo   = arrayfun(@(dp,iv) obj.Info(dp).selectVariable(iv),dp,dv);
    iinfo   = cellfun(@(dp,iv) obj.Info(dp).selectVariable(iv),num2cell(dp),iv);

    dinfo2      = DataKit.Metadata.info;
    iinfo2      = DataKit.Metadata.info;
	switch groupBy
        case {'','Variable'}
%             ind         = sub2ind([1,nVariable],uVariableIdx);
%             ddata2      = DataKit.accumcell(uVariableIdx,ddata,[1,nVariable],@(x) cat(1,x{:}));
%             try
%             idata2      = DataKit.accumcell(uVariableIdx,idata,[1,nVariable],@(x) cat(2,x{:}));
%             catch
%                 
%             end
%             idata2(ind) = cellfun(@(c) arrayfun(@(dim) cat(1,c{dim,:}),(1:size(c,1))','un',0)',idata2(ind),'un',0);
            
            dinfo2(uVariableIdx)   = dinfo(uVariableIdx);
            iinfo2(uVariableIdx)   = iinfo(uVariableIdx);
            data.IndepInfo  = struct(...
                                'Variable',             cat(2,iinfo2.Variable),...
                                'MeasurementDevice',    []);
            data.DepInfo    = struct(...
                                'Variable',             cat(2,dinfo2.Variable),...
                                'MeasurementDevice',    []);
        case 'MeasuringDevice'
%             ind         = sub2ind([nMeasuringDevices,nVariable],uMeasuringDevicesIdx,uVariableIdx);
%             ddata2      = DataKit.accumcell([uMeasuringDevicesIdx,uVariableIdx],ddata,[nMeasuringDevices,nVariable],@(x) cat(1,x{:}));
%             idata2      = DataKit.accumcell([uMeasuringDevicesIdx,uVariableIdx],idata,[nMeasuringDevices,nVariable],@(x) cat(2,x{:}));
%             idata2(ind) = cellfun(@(c) arrayfun(@(dim) cat(1,c{dim,:}),(1:size(c,1))','un',0)',idata2(ind),'un',0);

            dinfo2(uVariableIdx)   = dinfo(uVariableIdx);
            iinfo2(uVariableIdx)   = iinfo(uVariableIdx);
            dinfo2          = repmat(dinfo2,nMeasuringDevices,1);
            data.IndepInfo  = struct(...
                                'Variable',             cat(2,iinfo2.Variable),...
                                'MeasurementDevice',    uMeasuringDevices);
            data.DepInfo    = struct(...
                                'Variable',             cat(2,dinfo2.Variable),...
                                'MeasurementDevice',    uMeasuringDevices);
	end

    if nVariable <= 1 && ~forceCellOutput
        data.IndepData	= iData{1};
        data.DepData    = dData{1};
    else
        data.IndepData	= iData;
        data.DepData    = dData;
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
    defaultForceReturnIndependantVariable	= true;
    defaultRelativeTime                     = '';
    defaultGroupBy                          = '';
    defaultForceCellOutput                  = false;

    validRelativeTime   = {'milliseconds','seconds','minutes','hours','days','years'};
    validGropuBy        = {'Variable','MeasuringDevice'}; % 'MeasuringDeviceType','DataPool','VariableType'

    checkVariableType         	= @(x) (isempty(x) && isa(x,'double')) || ((ischar(x) || iscellstr(x)) && ismember(x,DataKit.Metadata.validators.validInfoVariableType.listAllValidInfoVariableType));
    checkMeasuringDevice        = @(x) (isempty(x) && isa(x,'double')) || isa(x,'GearKit.measuringDevice');
    checkMeasuringDeviceType    = @(x) (isempty(x) && isa(x,'double')) || ((ischar(x) || iscellstr(x)) && ismember(x,GearKit.measuringDeviceType.listAllMeasuringDeviceType));
    checkPoolIdx                = @(x) (isempty(x) && isa(x,'double')) || (isvector(x) && isnumeric(x) && all(x <= obj.PoolCount));
    checkVarIdx                 = @(x) (isempty(x) && isa(x,'double')) || (isvector(x) && isnumeric(x) && all(x <= max(obj.Index{:,'VariableIndex'})));

    isScalarLogical    	= @(x) isscalar(x) && islogical(x);
    checkRelativeTime   = @(x) any(validatestring(x,validRelativeTime));
    checkGroupBy        = @(x) any(validatestring(x,validGropuBy));

    addRequired(p,'obj')
    addOptional(p,'variable',defaultVariable,@checkVariable)
    addOptional(p,'variableType',defaultVariableType,checkVariableType)
    addOptional(p,'measuringDevice',defaultMeasuringDevice,checkMeasuringDevice)
    addOptional(p,'measuringDeviceType',defaultMeasuringDeviceType,checkMeasuringDeviceType)
    addOptional(p,'poolIdx',defaultPoolIdx,checkPoolIdx)
    addOptional(p,'varIdx',defualtVarIdx,checkVarIdx)
    addParameter(p,'Sort',defaultSort,isScalarLogical)
    addParameter(p,'ReturnRawData',defaultReturnRawData,isScalarLogical)
    addParameter(p,'ForceReturnIndependantVariable',defaultForceReturnIndependantVariable,isScalarLogical)
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
    forceReturnIndependantVariable  = p.Results.ForceReturnIndependantVariable;
    relativeTime                    = p.Results.RelativeTime;
    groupBy                         = p.Results.GroupBy;
    forceCellOutput               	= p.Results.ForceCellOutput;

    if isnumeric(variable)
        variable = variable2str(DataKit.Metadata.variable.id2variable(variable));
    end

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
                    forceReturnIndependantVariable,...
                    relativeTime,...
                    groupBy,...
                    forceCellOutput...
                  };
    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Parsed variable number mismatches the output.')
	end
end

function bool = checkVariable(x)
    validVariable   = DataKit.Metadata.variable.listAllVariables;
    validVariableId = DataKit.Metadata.variable.listAllVariableInfo.Id;
    if isa(x,'DataKit.Metadata.variable')
        bool = true;
    elseif iscellstr(x)
        bool = all(cellfun(@(y) any(validatestring(y,validVariable)),x));
    elseif ischar(x)
        if size(x,1) == 1
            bool = any(validatestring(x,validVariable));
        else
            error('DataKit:dataPool:fetchData:checkVariable:invalidCharShape',...
                'If variable is provided as a char, it has to be a vector of shape 1xn.\nIt was %s instead.\n',strjoin(cellstr(num2str(size(x)','%u')),' x '))
        end
    elseif isnumeric(x)
        if all(ismember(x,validVariableId))
            bool = true;
        else
         	error('DataKit:dataPool:fetchData:checkVariable:invalidVariableId',...
                '''%u'' is an invalid variable id. Valid id''s are:\n\t%s\nIt was %u instead.\n',strjoin(regexprep(cellstr(num2str(validVariableId)),'\s+',''),', '),x(find(~ismember(x,validVariableId),1)))
        end
    else
        error('DataKit:dataPool:fetchData:checkVariable:invalidType',...
            'Expected input ''variable'' to be one of these types:\n\tchar, cellstr, numeric\nIt was %s instead.\n',class(x))
    end
end
