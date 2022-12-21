function name = simplifyName(obj)

    if isa(obj.Value,'DataKit.Units.dimension')
        name = obj.Name;
        return
    end
    
    exponents   = strcat({'^'},strtrim(cellstr(num2str(obj.Degrees))));
    exponents   = regexprep(exponents,'^\^1$',''); % Remove power of 1

    % Sort the dimensions alphanumerically to allow consistent comparisons of two
    % dimensions (e.g. using eq())
    [dimensions,sortInd] = sort(obj.Dimensions);

    name        = strjoin(strcat(dimensions,exponents(sortInd)),'*');
end
