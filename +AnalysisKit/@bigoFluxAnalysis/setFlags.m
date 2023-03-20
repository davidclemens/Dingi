function setFlags(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFlags:settingFlags',...
        'Info','Setting flags ...')
    
    % Set flags for bad goodness of fit
    badGOF                      = false(1,obj.NFits);
    badGOF(obj.RateIndex)       = cat(1,obj.Fits.R2) < obj.FitR2Threshold;
    [flagBadGOFi,flagBadGOFj]   = find(badGOF);
    obj.FlagDataset             = obj.FlagDataset.setFlag('BadGoodnessOfFit',1,flagBadGOFi,flagBadGOFj);
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFlags:settingFlags',...
        'Info','Setting flags ... done')
end
