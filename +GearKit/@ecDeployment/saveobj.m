function s = saveobj(obj)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    propertyNames   = {};
    
    nProperties = numel(propertyNames);
    
    % Call superclass saveobj
    s = saveobj@GearKit.gearDeployment(obj);
    
    for pp = 1:nProperties
        printDebugMessage('Verbose','ecDeployment: Saving property %u of %u: ''%s''...',pp,nProperties,propertyNames{pp})
        
        s.(propertyNames{pp}) = obj.(propertyNames{pp});
    end
end