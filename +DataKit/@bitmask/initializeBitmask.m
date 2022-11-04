function obj = initializeBitmask(obj,i,j,bit,sz)

    import UtilityKit.Utilities.arrayhom
    import DataKit.bitmask.setbits

    [i,j,bit]   = arrayhom(i,j,bit);
    
    fillval     = 0;
    obj.Bits	= accumarray(cat(2,i,j),bit,sz,@setbits,fillval);
end