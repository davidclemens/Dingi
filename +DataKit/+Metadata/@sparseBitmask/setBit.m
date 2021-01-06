function obj = setBit(obj,i,j,bit,highlow)

    import DataKit.arrayhom
    
    if any(bit(:) > 52)
        error('DataKit:Metadata:sparseBitmask:setBit:bitPositionExceedsLimit',...
            'A bit position exceeds the limit. Only bits 1 to 52 can be set.')
    end
    
    if isempty(i) || isempty(j) || isempty(bit) || isempty(highlow)
        % if any of the relevant inputs is empty return the original object
        return
    end
    
    Sz  = obj.Sz;
    if any(i(:) > Sz(1)) || any(j(:) > Sz(2))
        warning('DataKit:Metadata:sparseBitmask:setBit:subscriptsExceedBitmaskSize',...
            'Subscript exceeds bitmask size. The Bitmask is extended')
        % extend bitmask
        newDimMax   = cat(1,max(i(:)),max(j(:)));
        for dim = 1:2
           	d   = newDimMax(dim) - Sz(dim);
            if d > 0
                newShape        = Sz;
                newShape(dim)   = d;
                obj.Bitmask     = cat(dim,obj.Bitmask,sparse(zeros(newShape)));
            end
            Sz  = obj.Sz; % update size
        end
    end
    
    highlow(highlow < 0) = 0;
    highlow(highlow > 0) = 1;
    
    [i,j,bit,highlow] = arrayhom(i,j,bit,highlow);
    
    n = numel(bit);
    for ii = 1:n
        A   = full(obj.Bitmask(i(ii),j(ii)));
        obj.Bitmask(i(ii),j(ii)) = bitset(A,bit(ii),highlow(ii));
    end
end