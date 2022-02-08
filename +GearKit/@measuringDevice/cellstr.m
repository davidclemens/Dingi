function C = cellstr(obj)
    
    if isempty(obj)
        C = cellstr(char.empty);
        return
    end
    
    sz     = size(obj);
    obj     = obj(:);
    
    deviceDomains = cat(1,obj.DeviceDomain);
    deviceDomainIsUndefined = arrayfun(@(dd) dd == 'undefined',deviceDomains);
    deviceDomainAbbreviation = reshape({deviceDomains.Abbreviation},[],1);
    deviceDomainAbbreviation(deviceDomainIsUndefined) = {'<undefined device domain>'};
    
    objInfo = strcat( ...
                cellstr(cat(1,obj.Type)),...
                {' ('},...
                deviceDomainAbbreviation,...
                {', SN:'},...
                reshape({obj.SerialNumber},[],1),...
                {')'});
            
	% Reshape to original size
    C = reshape(objInfo,sz);    
end