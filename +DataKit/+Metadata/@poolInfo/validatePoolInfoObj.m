function varargout = validatePoolInfoObj(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)

%     if obj.NoIndependentVariable && obj.VariableCount > 1
%         printDebugMessage('Dingi:DataKit:Metadata:info:missingIndependentVariable',...
%             'Warning','An independent variable is missing.')
%     end
    
    if nargout == 1
        varargout{1} = obj;
    end
end