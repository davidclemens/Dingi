function calculateFits(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Verbose','Calculating fits ...')
    
    switch obj.FitType
        case 'linear'
        otherwise
            printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:unknown',...
                'Error','Calculating fits ... done')    
    end
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Verbose','Calculating fits ... done')    
end