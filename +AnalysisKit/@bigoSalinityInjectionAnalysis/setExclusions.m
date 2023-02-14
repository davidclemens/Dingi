function setExclusions(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setExclusions:settingExclusions',...
        'Info','Setting exclusions ...')
    
    % Get the isSample & manual exclusions that are dependent only on the raw data and
    % are set in the setRawData method.
    isSample        = isFlag(obj.FlagData,'IsSample'); 
    excludeData     = isFlag(obj.FlagData,'IsManuallyExcludedFromFit');
        
    % Initialize flags
    obj.FlagDataset = DataKit.bitflag('AnalysisKit.Metadata.bigoSalinityInjectionAnalysisDatasetFlag',1,obj.NDeviceDomains);
    obj.FlagData    = DataKit.bitflag('AnalysisKit.Metadata.bigoSalinityInjectionAnalysisDataFlag',size(obj.Time_,1),obj.NDeviceDomains);

    % Flag manual exclusions
    [flagIsManuallyExcludedFromFiti,flagIsManuallyExcludedFromFitj] = find(excludeData);
    obj.FlagData            = obj.FlagData.setFlag('IsManuallyExcludedFromFit',1,flagIsManuallyExcludedFromFiti,flagIsManuallyExcludedFromFitj);
    
    % Flag samples
    [flagIsSamplei,flagIsSamplej] = find(isSample);
    obj.FlagData            = obj.FlagData.setFlag('IsSample',1,flagIsSamplei,flagIsSamplej);

    % Find NaNs
    flagIsNaN               = (isnat(obj.Time_) | isnan(obj.RawConductivity_) | isnan(obj.TemperatureRaw_)) & isSample;
    [flagIsNaNi,flagIsNaNj] = find(flagIsNaN);
    obj.FlagData            = obj.FlagData.setFlag('IsNaN',1,flagIsNaNi,flagIsNaNj);
    
    % Flag incubation time
    flagIsIncubation        = obj.Time >= obj.IncubationInterval(1) & obj.Time <= obj.IncubationInterval(2);
    [flagIsIncubationi,flagIsIncubationj] = find(flagIsIncubation);
    obj.FlagData            = obj.FlagData.setFlag('IsDuringIncubation',1,flagIsIncubationi,flagIsIncubationj);
    
    % Also set the dataset flag, if too many flags were raised.
    rIsNaN                  = sum(flagIsNaN,1)./sum(isSample,1);
    flagIsNaNThresholdExceeded  = rIsNaN > eval([obj.FlagDataset.EnumerationClassName,'.MissingDataThresholdExceeded.Threshold']);
    obj.FlagDataset         = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',flagIsNaNThresholdExceeded,1,1:obj.NDeviceDomains);
    
    obj.Exclude                 = ~isSample | flagIsNaN | excludeData;
    
    printDebugMessage('Dingi:AnalysisKit:bigoSalinityInjectionAnalysis:setExclusions:settingExclusions',...
        'Info','Setting exclusions ... done')
end
