function varargout = despike(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)
    
    datasetNames    = {'Velocity','FluxParameter'};
    
    for ds = 1:numel(datasetNames)
        printDebugMessage('Verbose','Despiking %s ...',datasetNames{ds})
        
        switch obj.DespikeMethod
            case 'none'
                % Do nothing
            case 'phase-space thresholding'
                obj.despikePST(datasetNames{ds});
            otherwise
                error('Dingi:AnalysisKit:eddyFluxAnalysis:despike:unknownDespikeMethod',...
                    '%s is an unknown despike method.',obj.DespikeMethod)
        end
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end