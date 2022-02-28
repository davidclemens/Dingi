function setRawData(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:settingRawData',...
        'Verbose','Setting raw data ...')
    
    timeData    = NaT(0,obj.NFits);
    fluxData    = NaN(0,obj.NFits);
    excludeData = false(0,obj.NFits);
    nSamples    = zeros(1,obj.NFits);
    for ff = 1:obj.NFits
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:settingRawDataVariable',...
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

        % Convert from duration to the set 'TimeUnit' for the fit
%         xData   = obj.TimeUnitFunction(data.IndepData{1} - obj.FitOriginTime(ff));
        xData   = data.IndepData{1};
        yData   = data.DepData;

        % Data is excluded from fitting if it has manually been marked as
        % rejected or if it falls outside the FitInterval.
        exclude     = isFlag(data.Flags,'ExcludeFromFit');        
        
        nSamples(ff)  	= numel(xData);
        
        % Grow matrix if necessary
        dN = nSamples(ff) - nSamplesMax;
        if dN > 0
            timeData    = cat(1,timeData,NaT(dN,obj.NFits));
            fluxData    = cat(1,fluxData,NaN(dN,obj.NFits));
            excludeData = cat(1,excludeData,false(dN,obj.NFits));
        end
        timeData(1:nSamples(ff),ff)     = xData;
        fluxData(1:nSamples(ff),ff)     = yData;
        excludeData(1:nSamples(ff),ff)	= exclude;        
    end
    
    isNaN   = isnat(timeData) | isnan(fluxData);
    
    obj.Time_ = timeData;
    obj.FluxParameter_ = fluxData;
    obj.Exclusions_ = excludeData | isNaN;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:settingRawData',...
        'Verbose','Setting raw data ... done')
end