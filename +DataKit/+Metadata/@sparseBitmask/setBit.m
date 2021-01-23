function obj = setBit(obj,i,j,bit,highlow)

% Note:
% if the same bit at the same index is adressed multiple times with
% differing highlow values, it will be set to '1' if at least one '1' for
% that bit in highlow exists and to '0' if no '1' for that bit in highlow
% exists.
%
% Example:
%   setBit(obj,2,3,[4,4,4,3],[0,0,0,1]) results in
%       (2,3) ...0100
%   while setBit(obj,2,3,[4,4,4,3],[1,1,0,1]) results in
%       (2,3) ...1100
%   even though the highest index highlow for bit 4 (index 3) is '0'.
%


    import DataKit.arrayhom
    
    if any(bit(:) > 52) || any(bit(:) < 1)
        error('Dingi:DataKit:Metadata:sparseBitmask:setBit:bitPositionExceedsLimit',...
            'A bit position exceeds the limits. Only bits 1 to 52 can be set.')
    end
    
    if isempty(i) || isempty(j) || isempty(bit) || isempty(highlow)
        % if any of the relevant inputs is empty return the original object
        return
    end
    
    Sz  = obj.Sz;
    if any(i(:) > Sz(1)) || any(j(:) > Sz(2))
        warning('Dingi:DataKit:Metadata:sparseBitmask:setBit:subscriptsExceedBitmaskSize',...
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
        
        ind                        	= sub2ind(obj.Sz,i,j);
        [indChange,~,indChangeInd]	= unique(ind);
        nIndChange                	= numel(indChange);
        
        indNoChange           	= setdiff(indBm,ind);
        
        % make sure these are column vectors
        indChangeInd	= indChangeInd(:);
        indChange   	= indChange(:);
        indNoChange     = indNoChange(:);
        
        nChange     	= numel(indChange);
        nNoChange    	= numel(indNoChange);
        
        bitmaskChange = full(obj.Bitmask(indChange));
        for ii = 1:nIndChange
            mask    = indChangeInd == ii;
            bitmaskChange(ii)	= sum(unique(bitset(bitmaskChange(ii),bit(mask),highlow(mask))));
        end
        obj.Bitmask(indChange)	= bitmaskChange;
        
        bitmaskNoChange         = full(obj.Bitmask(indNoChange));
        
        bitmask                 = spalloc(Sz(1),Sz(2),nNoChange + nChange);
        bitmask(indNoChange)	= bitmaskNoChange;
        bitmask(indChange)      = bitmaskChange;
        
        obj.Bitmask             = bitmask;
    end
    
%     for ii = 1:n
%         A   = full(obj.Bitmask(i(ii),j(ii)));
%         obj.Bitmask(i(ii),j(ii)) = bitset(A,bit(ii),highlow(ii));
%     end
end