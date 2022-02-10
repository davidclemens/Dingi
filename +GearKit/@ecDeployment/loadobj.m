function obj = loadobj(s)

    import DebuggerKit.Debugger.printDebugMessage
    
    % Check that a struct is loaded
    if ~isstruct(s)
        error('Dingi:GearKit:ecDeployment:loadobj:invalidVariableType',...
            'Invalid variable type.')
    end
    
    obj	= GearKit.ecDeployment();
    reloadobj(obj,s);
end
