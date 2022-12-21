function tf = eq(obj,B)

    inputs = {obj,B};
    isDimension = cat(2,isa(obj,'DataKit.Units.dimension'),isa(B,'DataKit.Units.dimension'));

    if sum(isDimension) == 2
        tf = strcmp(obj.Name,B.Name);
    elseif sum(isDimension) == 1
        if ischar(inputs{~isDimension})
            tf = strcmp(inputs{isDimension}.Name,inputs{~isDimension});
        else
            error('Dingi:DataKit:Units:dimension:eq:TypeError',...
                'A dimension instance can only be compared to another dimension or a char row vector.')
        end
    elseif sum(isDimension) == 0
        % This case will never be reached, as this is not a static method.
    end
end
