function obj = initializeBitmask(obj,i,j,bit,sz)

	import DataKit.Metadata.sparseBitmask.setbits
    import DataKit.arrayhom
    
    if any(bit(:) > 52)
        error('DataKit:Metadata:sparseBitmask:initializeBitmask:bitPositionExceedsLimit',...
            'A bit position exceeds the limit. Only bits 1 to 52 can be set.')
    end
    
    [i,j,bit]   = arrayhom(i,j,bit);
    
    fillval     = 0;
    isSparse    = true;
    obj.Bitmask	= accumarray(cat(2,i,j),bit,sz,@setbits,fillval,isSparse);
end