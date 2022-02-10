function obj = reloadobj(obj,s)

    import DebuggerKit.Debugger.printDebugMessage
    
    propertyNames   = {'protocol'...
        };
    nProperties     = numel(propertyNames);
                
    obj = reloadobj@GearKit.gearDeployment(obj,s);
    
    for pp = 1:nProperties
        printDebugMessage('Verbose','bigoDeployment: Loading property %u of %u: ''%s''...',pp,nProperties,propertyNames{pp})

        obj.(propertyNames{pp}) = s.(propertyNames{pp});
    end
end