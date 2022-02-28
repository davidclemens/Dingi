function calculateFits(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Verbose','Calculating fits ...')
    
    switch obj.FitType
        case 'linear'
            xData = obj.Time;
            yData = obj.FluxParameter;
            exData = obj.Exclusions;
            
            for ff = 1:obj.NFits
                [p,S,mu] = polyfit(xData(exData(:,ff),ff),yData(exData(:,ff),ff),1);
            end
        otherwise
            printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:unknown',...
                'Error','Calculating fits ... done')    
    end
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Verbose','Calculating fits ... done')    
end