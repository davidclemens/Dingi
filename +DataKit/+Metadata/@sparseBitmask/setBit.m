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
    
    if nnz(obj.Bitmask) == 0
        % no non-zero elements
        bitmaskNew 	= bitset(zeros(size(bit)),bit,highlow);
        obj.Bitmask	= sparse(i,j,bitmaskNew,Sz(1),Sz(2));
    else
        % non-zero elements already exist
        [iBm,jBm]           = find(obj.Bitmask);
        indBm               = sub2ind(obj.Sz,iBm,jBm);
        ind                 = sub2ind(obj.Sz,i,j);
        
        [indShared,iindShared]	= intersect(ind,indBm); % index 
        [indNew,iindNew]        = setdiff(ind,indBm);
        indOld                  = setdiff(indBm,ind);
        
        % make sure these are column vectors
        iindShared              = iindShared(:);
        indShared               = indShared(:);
        iindNew                 = iindNew(:);
        indNew                  = indNew(:);
        indOld                  = indOld(:);
        
        
        nShared             = numel(indShared);
        nNew                = numel(indNew);
        nOld                = numel(indOld);
        
        bitmaskShared       = bitset(full(obj.Bitmask(indShared)),bit(iindShared),highlow(iindShared));
        bitmaskNew          = bitset(zeros(nNew,1),bit(iindNew),highlow(iindNew));
        bitmaskOld          = full(obj.Bitmask(indOld));
        
        bitmask             = spalloc(Sz(1),Sz(2),nShared + nNew + nOld);
        bitmask(indShared)  = bitmaskShared;
        bitmask(indNew)     = bitmaskNew;
        bitmask(indOld)     = bitmaskOld;
        
        obj.Bitmask         = bitmask;
    end
    
%     for ii = 1:n
%         A   = full(obj.Bitmask(i(ii),j(ii)));
%         obj.Bitmask(i(ii),j(ii)) = bitset(A,bit(ii),highlow(ii));
%     end
end