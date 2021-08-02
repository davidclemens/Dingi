function disp(obj)
    
    dim     = size(obj);
    obj     = obj(:);
    
    if any(dim == 0)
        fprintf('%ux%u measuringDevice object\n',dim(1),dim(2))
        return
    end
    
    objInfo = cellstr(obj);
    
    disp(reshape(objInfo,dim))
end