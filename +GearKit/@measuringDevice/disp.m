function disp(obj)
    
    dim     = size(obj);
    obj     = obj(:);
    
    if any(dim == 0)
        fprintf('%ux%u measuringDevice object\n',dim(1),dim(2))
        return
    end
    deviceDomains = cat(1,obj.DeviceDomain);
    
    objInfo = categorical(strcat( ...
                cellstr(cat(1,obj.Type)),...
                {' ('},...
                reshape({deviceDomains.Abbreviation},[],1),...
                {', SN:'},...
                reshape({obj.SerialNumber},[],1),...
                {')'}));
    disp(reshape(objInfo,dim))
end