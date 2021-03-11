function obj = id2validflag(id)

    sz              = size(id);
    [tf,info]   	= DataKit.Metadata.validators.validFlag.validate('Id',id);
    
    if ~all(tf)
        error('Dingi:DataKit:Metadata:dataFlag:id2flag:invalidFlagId',...
            'The flag id %u is invalid.',id(find(~tf,1)))
    end
    
    obj     = reshape(cat(1,info.ValidFlag),sz);
end