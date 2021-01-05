function n = ndigits(a)
    
    if mod(10,1) ~= 0
        error('DataKit:ndigits:onlyIntegers',...
            'Only integers are allowed.')
    end
    
    if a ~= 0
        n = floor(log10(abs(a))) + 1;
    else
        n = 1;
    end
end