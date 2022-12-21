function C = times(obj,B)

    isDimension = cat(2,isa(obj,'DataKit.Units.dimension'),isa(B,'DataKit.Units.dimension'));
    if sum(isDimension) == 2
        name    = cat(2,obj.Name,'*',B.Name);
        value   = obj.Value.*B.Value;
    elseif isDimension(1) && ~isDimension(2)
        name    = obj.Name;
        value   = obj.Value;
    elseif ~isDimension(1) && isDimension(2)
        name    = B.Name;
        value   = B.Value;
    elseif ~isDimension(1) && ~isDimension(2)
        % This case will never be reached, as this is not a static method.
    end
    
    C = DataKit.Units.dimension(name,value);
end
