function tf = isequal(A,B)


    if ~isa(A,'DataKit.Metadata.poolInfo') || ~isa(B,'DataKit.Metadata.poolInfo')
        error('Dingi:DataKit:Metadata:poolInfo:isequal:invalidInputType',...
            'Inputs must be of type ''DataKit.Metadata.poolInfo''.')
    end

    A   = A(:);
    B   = B(:);
    nA  = numel(A);
    nB  = numel(B);

    if nA ~= nB
        error('Dingi:DataKit:Metadata:poolInfo:isequal:numberOfElementsDisagree',...
            'Inputs must have the same number of elements.')
    end

    metadata        = eval(['?',class(A)]);
    propertyNames   = {metadata.PropertyList.Name}';
    needsComparing  = find(~cat(1,metadata.PropertyList.Dependent));
    propertyIsEqual = false(numel(needsComparing),nA);
    for ee = 1:nA
        for ii = 1:numel(needsComparing)
            switch propertyNames{needsComparing(ii)}
                case 'VariableCalibrationFunction'
                    propertyIsEqual(ii,ee) = true;
                otherwise
                    propertyIsEqual(ii,ee) = isequal(A(ee).(propertyNames{needsComparing(ii)}),B(ee).(propertyNames{needsComparing(ii)}));
            end
        end
    end
    tf = all(all(propertyIsEqual,1));
end
