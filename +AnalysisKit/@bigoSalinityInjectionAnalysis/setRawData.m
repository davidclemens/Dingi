function setRawData(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRawData:settingRawData',...
        'Info','Setting raw data ...')
    
    timeData        = NaT(0,obj.NDeviceDomains,obj.NVariables);
    rawData         = NaN(0,obj.NDeviceDomains,obj.NVariables);
    excludeDataMarkedRejected = false(0,obj.NDeviceDomains,obj.NVariables);
    nSamples    = zeros(1,obj.NDeviceDomains,obj.NVariables);
    isSample    = false(0,obj.NDeviceDomains,obj.NVariables);
    for dd = 1:obj.NDeviceDomains
        
        printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRawData:settingRawDataVariable',...
            'Verbose','Setting raw data for device domain %u of %u: %s ...',dd,obj.NDeviceDomains,obj.DataDeviceDomains(dd))
        
        % Set current maximum number of samples
        nSamplesMax    = max(max(nSamples,[],3),[],2);
        
        for vv = 1:obj.NVariables
            % Get data pool & variable indices
            dp      = obj.PoolIndex(vv,dd);
            var     = obj.VariableIndex(vv,dd);

            % Fetch data
            data    = fetchData(obj.Parent.data,[],[],[],[],dp,var,...
                        'ForceCellOutput',  false,...
                        'GroupBy',          'Variable');
            xData   = data.IndepData{1};
            yData   = data.DepData;

            % Data is excluded from fitting if it has manually been marked as
            % rejected or if it falls outside the FitInterval.
            flagMarkedRejected 	= isFlag(data.Flags,'MarkedRejected');

            nSamples(1,dd,vv)  	= numel(xData);
            isSample(1:nSamples(dd),dd,vv) = true;

            % Grow matrix if necessary
            dN = nSamples(1,dd,vv) - nSamplesMax;
            if dN > 0
                timeData	= cat(1,timeData,NaT(dN,obj.NDeviceDomains,obj.NVariables));
                rawData     = cat(1,rawData,NaN(dN,obj.NDeviceDomains,obj.NVariables));
                excludeDataMarkedRejected = cat(1,excludeDataMarkedRejected,false(dN,obj.NDeviceDomains,obj.NVariables));
            end
            timeData(1:nSamples(1,dd,vv),dd,vv)	= xData;
            rawData(1:nSamples(1,dd,vv),dd,vv)	= yData;
            excludeDataMarkedRejected(1:nSamples(1,dd,vv),dd,vv)	= flagMarkedRejected;
        end
    end
    
    % Write to backend property
    obj.Time_               = timeData(:,:,1);
    obj.RawConductivity_ 	= rawData(:,:,1);
    obj.SalinityRaw_        = rawData(:,:,2);
    obj.TemperatureRaw_    	= rawData(:,:,3);
    obj.Pressure_           = obj.Parent.depth; % dbar
    
    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRawData:settingExclusionFlags',...
        'Verbose','Setting raw data exclusion flags ...')
    
    % Initialize flags
    obj.FlagData    = DataKit.bitflag('AnalysisKit.Metadata.bigoSalinityInjectionAnalysisDataFlag',size(timeData,1),size(timeData,2));
    
    % Flag samples
    [flagIsSamplei,flagIsSamplej] = find(all(isSample,3));
    obj.FlagData            = obj.FlagData.setFlag('IsSample',1,flagIsSamplei,flagIsSamplej);
    
    % Find marked rejections
    [flagIsMarkedRejectedi,flagIsMarkedRejectedj] = find(any(excludeDataMarkedRejected,3));
    obj.FlagData            = obj.FlagData.setFlag('IsManuallyExcludedFromFit',1,flagIsMarkedRejectedi,flagIsMarkedRejectedj);
        
    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRawData:settingExclusionFlags',...
        'Verbose','Setting raw data exclusion flags ... done')
    
    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setRawData:settingRawData',...
        'Info','Setting raw data ... done')
end
