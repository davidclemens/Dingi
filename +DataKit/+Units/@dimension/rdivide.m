function C = rdivide(obj,B)

    isDimension     	= cat(2,isa(obj,'DataKit.Units.dimension'),isa(B,'DataKit.Units.dimension'));
    if sum(isDimension) == 2
        name    = cat(2,obj.Name,'/(',B.Name,')');
        
        valueIsDimension 	= cat(2,isa(obj.Value,'DataKit.Units.dimension'),isa(B.Value,'DataKit.Units.dimension'));

        if valueIsDimension(1) && ~valueIsDimension(2)
            C = obj.Value./B;
            return
        elseif ~valueIsDimension(1) && valueIsDimension(2)
            C = obj./B.Value;
            return
        else
            value = obj.Value./B.Value;
        end
    elseif isDimension(1) && ~isDimension(2)
        C = obj;
        return
    elseif ~isDimension(1) && isDimension(2)
        name    = cat(2,'1/(',B.Name,')');
        value   = 1./B.Value;
    elseif ~isDimension(1) && ~isDimension(2)
        % This case will never be reached, as this is not a static method.
    end
    
    C = DataKit.Units.dimension(name,value);
end
