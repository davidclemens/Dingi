function tf = ge(a,b)

    if ischar(a)
        a = DebuggerKit.debugLevel.(a);
    end
    if ischar(b)
        b = DebuggerKit.debugLevel.(b);
    end
    
    
    if isa(a,'DebuggerKit.debugLevel')
        a = reshape(cat(1,a.Id),size(a));
    else
        error('Unsupported input type.')
    end
    if isa(b,'DebuggerKit.debugLevel')
        b = reshape(cat(1,b.Id),size(b));
    else
        error('Unsupported input type.')
    end
    
    tf      = a >= b;
end