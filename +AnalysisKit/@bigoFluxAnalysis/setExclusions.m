function setExclusions(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setExclusions:settingExclusions',...
        'Info','Setting exclusions ...')
    
    
    % Get the isSample & manual exclusions that are dependent only on the raw data and
    % are set in the setRawData method.
    isSample        = isFlag(obj.FlagData,'IsSample'); 
    excludeData     = isFlag(obj.FlagData,'IsManuallyExcludedFromFit');
    
    % Define the fit interval
    fitInterval             = obj.TimeUnitFunction(obj.FitInterval);
    isInFittingInterval     = obj.Time >= fitInterval(1) & obj.Time <= fitInterval(2);
    
    nSamplesInFitInterval	= sum(isSample & isInFittingInterval,1);
    
    % Initialize flags
    obj.FlagDataset = DataKit.bitflag('AnalysisKit.Metadata.bigoFluxAnalysisDatasetFlag',1,obj.NFits);
    obj.FlagData    = DataKit.bitflag('AnalysisKit.Metadata.bigoFluxAnalysisDataFlag',size(obj.Time_,1),obj.NFits);

    % Flag manual exclusions
    [flagIsManuallyExcludedFromFiti,flagIsManuallyExcludedFromFitj] = find(excludeData);
    obj.FlagData            = obj.FlagData.setFlag('IsManuallyExcludedFromFit',1,flagIsManuallyExcludedFromFiti,flagIsManuallyExcludedFromFitj);
    
    % Flag samples
    [flagIsSamplei,flagIsSamplej] = find(isSample);
    obj.FlagData            = obj.FlagData.setFlag('IsSample',1,flagIsSamplei,flagIsSamplej);

    % Find NaNs
    flagIsNaN               = (isnat(obj.Time_) | isnan(obj.FluxParameter_)) & isSample;
    [flagIsNaNi,flagIsNaNj] = find(flagIsNaN);
    obj.FlagData            = obj.FlagData.setFlag('IsNaN',1,flagIsNaNi,flagIsNaNj);
    
    % Flag samples outside the fitting interval
    [flagIsNotInFittingIntervali,flagIsNotInFittingIntervalj]     = find(~isInFittingInterval);
    obj.FlagData         	= obj.FlagData.setFlag('IsNotInFitInterval',1,flagIsNotInFittingIntervali,flagIsNotInFittingIntervalj);

    % Also set the dataset flag, if too many flags were raised.
    rIsNaN                  = sum(flagIsNaN & isInFittingInterval,1)./nSamplesInFitInterval;
    flagIsNaNThresholdExceeded  = rIsNaN > eval([obj.FlagDataset.EnumerationClassName,'.MissingDataThresholdExceeded.Threshold']);
    flagInsufficientFittingData = nSamplesInFitInterval - sum((flagIsNaN | excludeData) & isInFittingInterval,1) < obj.FitMinimumSamples;
    obj.FlagDataset         = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',flagIsNaNThresholdExceeded,1,1:obj.NFits);
   	obj.FlagDataset         = obj.FlagDataset.setFlag('InsufficientFittingData',flagInsufficientFittingData,1,1:obj.NFits);
    
    obj.Exclude                 = ~isSample | flagIsNaN | excludeData | ~isInFittingInterval;
    obj.ExcludeFluxParameter    = flagInsufficientFittingData;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setExclusions:settingExclusions',...
        'Info','Setting exclusions ... done')
end