function tf = eq(obj1,obj2)

    if isa(obj1,'DataKit.Metadata.dataFlag') && isa(obj2,'DataKit.Metadata.dataFlag')
        tf = isequal(obj1,obj2);
    elseif ischar(obj2)
        tf = obj1.isFlag(obj2);
    elseif ischar(obj1)
        tf = obj2.isFlag(obj1);
    else
        error('DataKit:Metadata:sparseBitmask:eq:invalidInputCombination',...
            'Undefined input combination.')
    end
end