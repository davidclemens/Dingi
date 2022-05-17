function tf = isequal(A,B)
    

    if ~isa(A,'DataKit.dataPool') || ~isa(B,'DataKit.dataPool')
        error('Dingi:DataKit:dataPool:isequal:invalidInputType',...
            'Inputs must be of type ''DataKit.dataPool''.')
    end
    
    metadata        = eval(['?',class(A)]);
    propertyNames   = {metadata.PropertyList.Name}';
    needsComparing  = find(~any(cat(2,cat(1,metadata.PropertyList.Dependent),...
                                      strcmp(propertyNames,'IndexNeedsUpdating'),...
                                      strcmp(propertyNames,'Index')),2));
    propertyIsEqual = false(numel(needsComparing),1);
    for ii = 1:numel(needsComparing)
        propertyIsEqual(ii) = isequal(A.(propertyNames{needsComparing(ii)}),B.(propertyNames{needsComparing(ii)}));
    end
    tf = all(propertyIsEqual);
end