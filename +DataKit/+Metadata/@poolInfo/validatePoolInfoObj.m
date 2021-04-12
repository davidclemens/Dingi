function varargout = validatePoolInfoObj(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)

    if obj.NoIndependantVariable == 0 && obj.VariableCount > 1
        printDebugMessage('Dingi:DataKit:Metadata:info:missingIndependantVariable',...
            'Warning','An independant variable is missing.')
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end