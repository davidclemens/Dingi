function calculateFits(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ...')
    
    rateIndex 	= obj.RateIndex;
    nRates    	= obj.NRates;
    
    fits        = struct('Index',num2cell(obj.RateIndex'));
    
    xData = obj.Time;
    yData = obj.FluxParameter;
    exData = obj.Exclude;

    for rr = 1:nRates
        fi = rateIndex(rr);

        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:fitting',...
            'Verbose','Fitting flux parameter %u of %u: %s %s ...',rr,nRates,obj.FitDeviceDomains(fi),obj.FitVariables(fi))
        
        X = xData(~exData(:,fi),fi);
        Y = yData(~exData(:,fi),fi);
        switch obj.FitTypes{fi}
            case {'linear','poly1'}
                [p,S]   = polyfit(X,Y,1);
                R2      = errorEst2R2(S.normr,Y);
            case {'poly2'}
                [p,S]   = polyfit(X,Y,2);
                R2      = errorEst2R2(S.normr,Y);
            case {'poly3'}
                [p,S]   = polyfit(X,Y,3);
                R2      = errorEst2R2(S.normr,Y);
        end
        fits(rr).Coeff  = p;
        fits(rr).ErrEst = S;
        fits(rr).R2     = R2;
    end
    
    obj.Fits_ = fits;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ... done')
    
    function R2 = errorEst2R2(normr,y)
        R2 = 1 - (normr/norm(y - mean(y)))^2;
    end
end
