function obj = reloadobj(obj,s)

    import DebuggerKit.Debugger.printDebugMessage
    
    propertyNames   = {...
        };
    nProperties     = numel(propertyNames);
                
    obj = reloadobj@GearKit.gearDeployment(obj,s);
    
    for pp = 1:nProperties
        printDebugMessage('Verbose','ecDeployment: Loading property %u of %u: ''%s''...',pp,nProperties,propertyNames{pp})

        obj.(propertyNames{pp}) = s.(propertyNames{pp});
    end
end