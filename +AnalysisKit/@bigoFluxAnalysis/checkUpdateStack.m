function varargout = checkUpdateStack(obj,stackDepth)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)
    
    updating        = any(obj.UpdateStack(1:stackDepth) == 1);
    if updating
        % A dependency is currently updating
        return
    end
    
    updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    
    while updateRequired
        updateIndex = find(obj.UpdateStack(1:stackDepth) == 2,1);
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:checkUpdateStack:updating',...
            'Verbose','Updating stack depth %u ...',updateIndex)
        
        switch updateIndex
            case 1
              	setFitVariables(obj)
                setRawData(obj)
                
            case 2
                
        end
        
        % Set the current update index to 'Updated'
        obj.UpdateStack(updateIndex) = 0;
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:checkUpdateStack:updating',...
            'Verbose','Updating stack depth %u ... done',updateIndex)
        
        updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end