function y = downsample(x,N)
% SUBSAMPLE

    validateattributes(N,{'numeric'},{'scalar','integer','nonzero','positive'});
    
    if N == 1
        y = x;
        return
    end
    
    n       = size(x,1);
    indEnd  = n - mod(n,N);
    ind     = 1:indEnd;
    y       = shiftdim(mean(reshape(shiftdim(x(ind,:),-1),[N,indEnd/N,size(x,2)]),1));
end