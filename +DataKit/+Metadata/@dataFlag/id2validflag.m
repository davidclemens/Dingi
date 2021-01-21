function obj = id2validflag(id)

	if ~isnumeric(id)
        error('DataKit:Metadata:dataFlag:id2flag:invalidDataType',...
            'The input argument ''id'' has to be numeric.')
	end
    
    flagListInfo	= DataKit.Metadata.validators.validFlag.listAllValidFlagInfo();
    [im,imIdx]   	= ismember(id,flagListInfo{:,'Id'});
    
    if ~all(im)
        error('DataKit:Metadata:dataFlag:id2flag:invalidFlagId',...
            'The flag id %u is invalid.',id(find(~im,1)))
    end
    
    obj     = flagListInfo{imIdx,'Flag'};
end