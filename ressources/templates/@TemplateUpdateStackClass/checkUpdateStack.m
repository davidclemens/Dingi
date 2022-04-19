function checkUpdateStack(obj,stackDepth)
% checkUpdateStack  Check if updates are pending
%   CHECKUPDATESTACK checks the update stack for pending updates and calls the
%   required update function to update all stack depths below the pending
%   update.

    import DebuggerKit.Debugger.printDebugMessage
    
    updating        = any(obj.UpdateStack(1:stackDepth) == 1);
    if updating
        % A dependency is currently updating
        return
    end
    
    updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    
    while updateRequired
        updateIndex = find(obj.UpdateStack(1:stackDepth) == 2,1);
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:checkUpdateStack:updating',...
            'Info','Updating stack depth %u ...',updateIndex)
        
        switch updateIndex
            case 1
                % Call methods that update stack depth 1
            case 2
                % Call methods that update stack depth 2
            case 3
                % Call methods that update stack depth 3                
        end
        
        % Set the current update index to 'Updated'
        obj.setUpdateStackToUpdated(updateIndex)
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:checkUpdateStack:updating',...
            'Info','Updating stack depth %u ... done',updateIndex)
        
        updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    end
end
