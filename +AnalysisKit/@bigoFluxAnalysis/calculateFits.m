function calculateFits(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ...')
    
    rateIndex 	= obj.RateIndex;
    nRates    	= obj.NRates;
    
    fits        = struct('Index',num2cell(obj.RateIndex'));
    switch obj.FitType
        case 'linear'
            xData = obj.Time;
            yData = obj.FluxParameter;
            exData = obj.Exclude;
            
            for rr = 1:nRates
                fi = rateIndex(rr);
                
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:fitting',...
                    'Verbose','Fitting flux parameter %u of %u: %s %s ...',rr,nRates,obj.FitDeviceDomains(fi),obj.FitVariables(fi))
                
                [p,S] = polyfit(xData(~exData(:,fi),fi),yData(~exData(:,fi),fi),1);
                
                fits(rr).Coeff = p;
                fits(rr).ErrEst = S;
            end
    end
    
    obj.Fits_ = fits;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ... done')    
end