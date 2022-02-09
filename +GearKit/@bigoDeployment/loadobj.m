function obj = loadobj(s)

    import DebuggerKit.Debugger.printDebugMessage
    
    % Check that a struct is loaded
    if ~isstruct(s)
        error('Dingi:GearKit:bigoDeployment:loadobj:invalidVariableType',...
            'Invalid variable type.')
    end
    
    obj	= GearKit.bigoDeployment();
    reloadobj(obj,s);
end
