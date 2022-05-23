function disp(obj)
    
    dim     = size(obj);
    obj     = obj(:);
    
    if any(dim == 0)
        fprintf('%ux%u validUnit object\n',dim(1),dim(2))
        return
    end
    objInfo	= categorical(strcat(obj.cellstr,...
                {' ('},...
                arrayfun(@(o) sprintf('%u',o),cat(1,obj.Id),'un',0),...
                {', '},...
                cat(1,{obj.Symbol})',...
                {')'}));
    disp(reshape(objInfo,dim))
end
