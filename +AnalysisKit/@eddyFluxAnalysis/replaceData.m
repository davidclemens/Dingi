function varargout = replaceData(obj,flag)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)
    
    printDebugMessage('Verbose','Replacing data flagged as ''%s'' ...',flag)
    
    dataSetNames    = {'Velocity','FluxParameter'};

    for ds = 1:numel(dataSetNames)
        dataSetNameQC  = [dataSetNames{ds},'QC'];
        dataSetNameFlag = ['Flag',dataSetNames{ds}];
        
        mask    = isFlag(obj.(dataSetNameFlag),flag);
        data    = obj.(dataSetNameQC);
        
        nSeries = size(mask,2);
        isInterpolated  = false(size(mask));
        isSetToNaN      = false(size(mask));
        for ser = 1:nSeries
            if sum(mask(:,ser)) == 0
                return
            end
            [data(:,ser),isInterpolated(:,ser),isSetToNaN(:,ser)] = replaceData(obj,data(:,ser),mask(:,ser));
            obj.(dataSetNameFlag) = setFlag(obj.(dataSetNameFlag),'IsInterpolated',1,find(isInterpolated(:,ser)),ser);
            obj.(dataSetNameFlag) = setFlag(obj.(dataSetNameFlag),'IsSetToNaN',1,find(isSetToNaN(:,ser)),ser);
        end
        obj.(dataSetNameQC) = data;
        
        if sum(isInterpolated(:)) > 0
            printDebugMessage('Verbose','Replaced %u data samples in %s flagged as ''%s'' ... done',sum(isInterpolated(:)),dataSetNames{ds},flag)
        end
        if sum(isSetToNaN(:)) > 0
            printDebugMessage('Verbose','Set %u data samples to ''NaN'' in %s flagged as ''%s'' ... done',sum(isSetToNaN(:)),dataSetNames{ds},flag)
        end
    end
    
    printDebugMessage('Verbose','Replacing data flagged as ''%s'' ... done',flag)
    
    if nargout == 1
        varargout{1} = obj;
    end
    
    function [replacedData,isInterpolated,isSetToNaN] = replaceData(obj,data,flag)
        
        replacedData    = data;
        isInterpolated  = false(size(data));
        isSetToNaN      = false(size(data));
        if sum(flag) == 0 || strcmp(obj.ReplaceMethod,'none')
            return
        end
        threshold   = 3;
        
        run = getFlagRuns(flag);
        
        shortRun    = run(run(:,4) <= threshold,:);
        longRun     = run(run(:,4) > threshold,:);
        
        % Treat short runs as long runs, if they occur at the beginning or at the
        % end of the data
        if shortRun(1,2) == 1
            longRun         = [longRun;shortRun(1,:)];
            shortRun(1,:)   = [];
        end
        if shortRun(end,3) == numel(data)
            longRun         = [longRun;shortRun(end,:)];
            shortRun(end,:)	= [];
        end
        
        % First replace flagged runs with length > threshold with NaNs and set
        % the appropriate flag
        for rr = 1:size(longRun,1)
            replacedData(longRun(rr,2):longRun(rr,3)) = NaN;
            isSetToNaN(longRun(rr,2):longRun(rr,3)) = true;
        end
        
        % Now replace flagged runs with length <= threshold with the selected
        % interpolation method and set the appropriate flag
        switch obj.ReplaceMethod
            case 'linear'
                for rr = 1:size(shortRun,1)
                    
                    x   = [1,shortRun(rr,4) + 2];
                    v   = replacedData([shortRun(rr,2) - 1,shortRun(rr,3) + 1]);
                    xq  = 2:shortRun(rr,4) + 1;
                    replacedData(shortRun(rr,2):shortRun(rr,3)) = interp1(x,v,xq,'linear');
                    
                    isInterpolated(shortRun(rr,2):shortRun(rr,3)) = true;
                end
            otherwise
                error('unknown replace method')
        end
    end

    function run = getFlagRuns(flag)
        df = [0;diff(flag)];
        
        runStartPositions   = find(df == 1);
        runEndPositions     = find(df == -1) - 1;
        if flag(1) == 1
            runStartPositions = [1;runStartPositions];
        end
        if flag(end) == 1
            runEndPositions = [runEndPositions;numel(flag)];
        end
        runLength   = runEndPositions - runStartPositions + 1;
        
        run = cat(2,(1:numel(runStartPositions))',runStartPositions,runEndPositions,runLength);
    end
end