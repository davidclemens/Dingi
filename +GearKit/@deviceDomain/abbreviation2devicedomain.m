function obj = abbreviation2devicedomain(abbr)

	if ~(iscellstr(abbr) || ischar(abbr))
        error('Dingi:GearKit:deviceDomain:abbreviation2devicedomain:invalidInputType',...
            'Input must be cellstr or char.')
	end
    if ischar(abbr)
        abbr    = cellstr(abbr);
    end
    nAbbr   = numel(abbr);
    
    allDeviceDomains = enumeration('GearKit.deviceDomain');
    allDeviceDomainAbbreviations    = {allDeviceDomains.Abbreviation}';
    
    [im,imInd]    = ismember(abbr,allDeviceDomainAbbreviations);
    
    if sum(im) ~= nAbbr
        error('Dingi:GearKit:deviceDomain:abbreviation2devicedomain:invalidAbbreviation',...
            '''%s'' is an invalid abbreviation. Valid abbreviations are:\n\t%s\n',abbr{find(~im,1)},strjoin(allDeviceDomainAbbreviations,', '))
    end
    
    obj     = allDeviceDomains(imInd(im));
end