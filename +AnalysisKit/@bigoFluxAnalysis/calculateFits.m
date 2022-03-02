function calculateFits(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ...')
    
    fitIndex	= find(~obj.ExcludeFluxParameter);
    nFits       = numel(fitIndex);
    
    fits        = struct('Index',num2cell(fitIndex'));
    switch obj.FitType
        case 'linear'
            xData = obj.Time;
            yData = obj.FluxParameter;
            exData = obj.Exclude;
            
            for ff = 1:nFits
                fi = fitIndex(ff);
                
                [p,S,mu] = polyfit(xData(~exData(:,fi),fi),yData(~exData(:,fi),fi),1);
                
                fits(ff).Coeff = p;
                fits(ff).ErrEst = S;
                fits(ff).Scaling = mu;
            end
        otherwise
            printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:unknown',...
                'Error','Calculating fits ... done')    
    end
    
    obj.Fits_ = fits;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFits:calculatingFits',...
        'Info','Calculating fits ... done')    
end