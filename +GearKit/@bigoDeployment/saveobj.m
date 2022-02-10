function s = saveobj(obj)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    propertyNames   = {'protocol'...
                        };
    
    nProperties = numel(propertyNames);
    
    % Call superclass saveobj
    s = saveobj@GearKit.gearDeployment(obj);
    
    for pp = 1:nProperties
        printDebugMessage('Verbose','bigoDeployment: Saving property %u of %u: ''%s''...',pp,nProperties,propertyNames{pp})
        
        s.(propertyNames{pp}) = obj.(propertyNames{pp});
    end
end