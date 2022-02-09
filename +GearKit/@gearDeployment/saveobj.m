function s = saveobj(obj)
    
    import DebuggerKit.Debugger.printDebugMessage

    metadata = eval(['?',class(obj)]);
    
    propertyNames   = {metadata.PropertyList.Name}';
    needsSaving     = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                cat(1,metadata.PropertyList.Constant),...
                                cat(1,metadata.PropertyList.Dependent)),2));
    nProperties     = numel(needsSaving);
    s = struct();
    for pp = 1:nProperties
        printDebugMessage('Verbose','Saving property %u of %u: ''%s''...',pp,nProperties,propertyNames{needsSaving(pp)})
        
        s.(propertyNames{needsSaving(pp)}) = obj.(propertyNames{needsSaving(pp)});
    end
    
    % Properties only stored in the saved struct, not the gearDeployment instance
    s.saveDate              = datetime('now');
    s.toolboxVersion        = getToolboxVersion();
    s.dataStructureVersion  = obj.dataStructureVersion;
end