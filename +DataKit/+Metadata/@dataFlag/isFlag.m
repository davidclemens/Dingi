function tf = isFlag(obj,flag)

    if ~ischar(flag) && ~isscalar(flag)
        error('DataKit:Metadat:dataFlag:isFlag:onlyScalarContextAllowed',...
            '''flag'' has to be scalar.')
    end
    
    if isnumeric(flag)
        [isValid,info]	= DataKit.Metadata.dataFlag.validateId(flag);
        Flag            = info{isValid,'Flag'};
    else
        Flag = DataKit.Metadata.validators.validFlag(flag);
    end
    
    [i,j,bm] = find(obj.Bitmask);
    
    tf                       = false(size(obj));
  	tf(sub2ind(obj.Sz,i,j))  = logical(bitget(bm,Flag.Id));
end