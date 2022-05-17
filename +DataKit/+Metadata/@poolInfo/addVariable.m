function varargout = addVariable(obj,variable,varargin)
    
    import internal.stats.parseArgs
    import DataKit.arrayhom
    import DataKit.Metadata.poolInfo
    
    nargoutchk(0,1)
    
    if numel(obj) > 1
        error('DataKit:Metadata:poolInfo:addVariable:NonScalarContext',...
            'Only works in a scalar context.')
    end
    
    % Cast variable to DataKit.Metadata.variable if necessary
    if ~isa(variable,'DataKit.Metadata.variable')
        variable = DataKit.Metadata.variable(variable);
    end
    
    optionName          = {'VariableType','VariableCalibrationFunction','variableDescription','variableMeasuringDevice','VariableOrigin'}; % valid options (Name)
    optionDefaultValue  = {{'undefined'},{@(x) x},{''},GearKit.measuringDevice(),{0}}; % default value (Value)
    [variableType,...
     variableCalibrationFunction,...
     variableDescription,...
     variableMeasuringDevice,...
     variableOrigin...
        ]               = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    % Homogenize the inputs
    [variable,...
     variableType,...
     variableCalibrationFunction,...
     variableDescription,...
     variableMeasuringDevice,...
     variableOrigin...
        ] = arrayhom(variable,variableType,variableCalibrationFunction,variableDescription,variableMeasuringDevice,variableOrigin);
    
    % Reshape vectors to row vectors
    variable                        = reshape(variable,1,[]);
    variableType                  	= reshape(variableType,1,[]);
    variableCalibrationFunction    	= reshape(variableCalibrationFunction,1,[]);
    variableDescription          	= reshape(variableDescription,1,[]);
    variableMeasuringDevice     	= reshape(variableMeasuringDevice,1,[]);
    variableOrigin                  = reshape(variableOrigin,1,[]);
    
    % Append. Using subscripted assignment to be able to call addVariable
    % on an empty instance of poolInfo
    obj(1).Variable                    = cat(2,obj.Variable,variable);
    obj(1).VariableRaw                 = cat(2,obj.VariableRaw,variable);
    obj(1).VariableType                = cat(2,obj.VariableType,variableType);
    obj(1).VariableCalibrationFunction = cat(2,obj.VariableCalibrationFunction,variableCalibrationFunction);
    obj(1).VariableDescription         = cat(2,obj.VariableDescription,variableDescription);
    obj(1).VariableMeasuringDevice     = cat(2,obj.VariableMeasuringDevice,variableMeasuringDevice);
    obj(1).VariableOrigin              = cat(2,obj.VariableOrigin,variableOrigin);
    
    sz  = size(variable);
    obj(1).VariableFactor              = cat(2,obj.VariableFactor,ones(sz));
    obj(1).VariableOffset              = cat(2,obj.VariableOffset,zeros(sz));

    obj.validatePoolInfoObj;
    
    if nargout == 1
        varargout{1} = obj;
    end
end
