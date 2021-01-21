function tf = eq(obj1,obj2)

    if isa(obj1,'DataKit.Metadata.sparseBitmask') && isa(obj2,'DataKit.Metadata.sparseBitmask')
        tf = isequal(obj1,obj2);
    elseif isnumeric(obj2) && isscalar(obj2)
        tf = obj1.isFlag(obj2);
    elseif isnumeric(obj1) && isscalar(obj1)
        tf = obj2.isFlag(obj1);
    else
        error('DataKit:Metadata:sparseBitmask:eq:invalidInputCombination',...
            'Undefined input combination.')
    end
end