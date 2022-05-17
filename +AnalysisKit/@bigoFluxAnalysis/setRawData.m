function setRawData(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setRawData:settingRawData',...
        'Info','Setting raw data ...')
    
    timeData    = NaT(0,obj.NFits);
    fluxData    = NaN(0,obj.NFits);
    excludeDataMarkedRejected = false(0,obj.NFits);
    excludeDataExcludeFromFit = false(0,obj.NFits);
    nSamples    = zeros(1,obj.NFits);
    isSample    = false(0,obj.NFits);
    for ff = 1:obj.NFits
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setRawData:settingRawDataVariable',...
            'Verbose','Setting raw data %u of %u: %s %s ...',ff,obj.NFits,obj.FitDeviceDomains(ff),obj.FitVariables(ff))
        
        % Set current maximum number of samples
        nSamplesMax    = max(nSamples);
        
        % Get data pool & variable indices
        dp      = obj.PoolIndex(ff);
        var     = obj.VariableIndex(ff);

        % Fetch data
        data    = fetchData(obj.Parent.data,[],[],[],[],dp,var,...
                    'ForceCellOutput',  false,...
                    'GroupBy',          'Variable');

        xData   = data.IndepData{1};
        yData   = data.DepData;

        % Data is excluded from fitting if it has manually been marked as
        % rejected or if it falls outside the FitInterval.
        flagMarkedRejected 	= isFlag(data.Flags,'MarkedRejected');
        flagExcludeFromFit 	= isFlag(data.Flags,'ExcludeFromFit');
        
        nSamples(ff)  	= numel(xData);
        isSample(1:nSamples(ff),ff) = true;
        
        % Grow matrix if necessary
        dN = nSamples(ff) - nSamplesMax;
        if dN > 0
            timeData    = cat(1,timeData,NaT(dN,obj.NFits));
            fluxData    = cat(1,fluxData,NaN(dN,obj.NFits));
            excludeDataMarkedRejected = cat(1,excludeDataMarkedRejected,false(dN,obj.NFits));
            excludeDataExcludeFromFit = cat(1,excludeDataExcludeFromFit,false(dN,obj.NFits));
        end
        timeData(1:nSamples(ff),ff)     = xData;
        fluxData(1:nSamples(ff),ff)     = yData;
        excludeDataMarkedRejected(1:nSamples(ff),ff)	= flagMarkedRejected;     
        excludeDataExcludeFromFit(1:nSamples(ff),ff)	= flagExcludeFromFit;        
    end
    
    % Write to backend property
    obj.Time_ = timeData;
    obj.FluxParameter_ = fluxData;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setRawData:settingExclusionFlags',...
        'Verbose','Setting raw data exclusion flags ...')
    
    % Initialize flags
    obj.FlagData    = DataKit.bitflag('AnalysisKit.Metadata.bigoFluxAnalysisDataFlag',size(timeData,1),obj.NFits);
    
    % Flag samples
    [flagIsSamplei,flagIsSamplej] = find(isSample);
    obj.FlagData            = obj.FlagData.setFlag('IsSample',1,flagIsSamplei,flagIsSamplej);
    
    % Find marked rejections
    [flagIsMarkedRejectedi,flagIsMarkedRejectedj] = find(excludeDataMarkedRejected);
    obj.FlagData            = obj.FlagData.setFlag('IsManuallyExcludedFromFit',1,flagIsMarkedRejectedi,flagIsMarkedRejectedj);
    
    % Find fit exclusions
    [flagIsExcludedFromFiti,flagIsExcludedFromFitj] = find(excludeDataExcludeFromFit);
    obj.FlagData            = obj.FlagData.setFlag('IsManuallyExcludedFromFit',1,flagIsExcludedFromFiti,flagIsExcludedFromFitj);
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setRawData:settingExclusionFlags',...
        'Verbose','Setting raw data exclusion flags ... done')
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setRawData:settingRawData',...
        'Info','Setting raw data ... done')
end