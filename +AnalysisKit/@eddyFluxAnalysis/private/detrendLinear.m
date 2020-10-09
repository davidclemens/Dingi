function y = detrendLinear(x)
% DETRENDLINEAR    

    import GearKit.fitLinear
    
    meanValue	= NaN(size(x));
    xq          = (1:size(x,1))';
    for ii = 1:size(x,3)
        for jj = 1:size(x,2)
            func                = fitLinear(xq,x(:,jj,ii));
            meanValue(:,jj,ii)	= func(xq);
        end
    end
    y = x - meanValue;
end