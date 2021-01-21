function s = saveobj(obj)

    metadata = eval(['?',class(obj)]);
    
    propertyNames   = {metadata.PropertyList.Name}';
    needsSaving     = find(~any(cat(2,cat(1,metadata.PropertyList.Transient),...
                                cat(1,metadata.PropertyList.Constant),...
                                cat(1,metadata.PropertyList.Dependent)),2));
    
    s = struct();
    for pp = 1:numel(needsSaving)
        s.(propertyNames{needsSaving(pp)}) = obj.(propertyNames{needsSaving(pp)});
    end
    s.saveDate = datetime('now');
    s.toolboxVersion = getToolboxVersion();
end