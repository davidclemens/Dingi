function runAnalysis(obj)

    import AnalysisKit.bigoFluxAnalysis
    import DebuggerKit.Debugger.printDebugMessage
    
    printDebugMessage('Info','Running BIGO analysis...')
    
    relativeTimeUnit	= 'h';
    fitInterval         = hours([0,4]);
    fitType             = 'sigmoidal';
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
        printDebugMessage('Verbose','Running analysis for BIGO %u of %u...',oo,nObj)
        
        obj(oo).analysis	= bigoFluxAnalysis(obj(oo),...
                                'FitType',                  fitType,...
                                'FitEvaluationInterval',   	fitInterval,...
                                'TimeUnit',                 relativeTimeUnit);
    end
    
    printDebugMessage('Info','Running BIGO analysis... done')
end