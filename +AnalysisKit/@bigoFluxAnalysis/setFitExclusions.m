function setFitExclusions(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    printDebugMessage('Info','%s: Setting %u fit exclusion(s) ...',obj.Parent.gearId,obj.NFits)
    
    for ff = 1:obj.NFits
        printDebugMessage('Verbose','%s: Setting fit exclusions for variable %u of %u (%s) ...',obj.Parent.gearId,ff,obj.NFits,obj.FitVariables(ff))
        
        % Get data pool & variable indices
        dp      = obj.PoolIndex(ff);
        var     = obj.VariableIndex(ff);
        
        % Fetch data
        data    = fetchData(obj.Bigo.data,[],[],[],[],dp,var,...
                    'ForceCellOutput',  false,...
                    'GroupBy',          'Variable');
        if ~isscalar([data.IndepInfo.Variable{:}]) || ~ismember('Time',[data.IndepInfo.Variable{:}])
            % Throw error if there are multiple independent variables or if
            % 'Time' is missing from the independent variables
            error('TODO: no time available')
        end
        
        xData   = data.IndepData{1} - obj.FitOriginTime(ff);
        
        % Data is excluded from fitting if it has manually been marked as
        % rejected or if it falls outside the FitInterval.
        exclude     = isFlag(data.Flags,'MarkedRejected') | ...
                      isFlag(data.Flags,'ExcludeFromFit') | ...
                      xData < obj.FitStartTime(ff) | ...
                      xData > obj.FitEndTime(ff);
                  
        % Set the 'ExcludeFromFit' flag to false to start from a clean
        % slate
        obj.Bigo.data = obj.Bigo.data.setFlag(dp,1:size(obj.Bigo.data.Data{dp},1),var,DataKit.Metadata.validators.validFlag.ExcludeFromFit.Id,0);
        
        % Set the 'ExcludeFromFit' flag to true for the excluded data
        if any(exclude)
            obj.Bigo.data = obj.Bigo.data.setFlag(dp,find(exclude),var,DataKit.Metadata.validators.validFlag.ExcludeFromFit.Id,1);
        end
    end
    
    printDebugMessage('Info','%s: Setting fit exclusions ... done',obj.Parent.gearId)
end