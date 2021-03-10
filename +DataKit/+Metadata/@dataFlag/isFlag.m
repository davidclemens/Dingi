function tf = isFlag(obj,flag)

    if ~ischar(flag) && ~isscalar(flag)
        error('Dingi:DataKit:Metadat:dataFlag:isFlag:onlyScalarContextAllowed',...
            '''flag'' has to be scalar.')
    end
    if (ischar(flag) && flag == DataKit.Metadata.validators.validFlag.fromProperty('Id',0)) || ...
       (isnumeric(flag) && flag == 0)
        error('Dingi:DataKit:Metadat:dataFlag:isFlag:flagHasToBeDefined',...
            '''flag'' has to be defined. You can''t test for ''undefined''.')
    end
    
    if isnumeric(flag)
        [isValid,info]	= DataKit.Metadata.validators.validFlag.validate('Id',flag);
    else
        [isValid,info]	= DataKit.Metadata.validators.validFlag.validate('ValidFlag',flag);
    end
    
    if ~isValid
        error('Dingi:DataKit:Metadat:dataFlag:isFlag:invalidFlag',...
            'The flag you want to test is invalid.')
    end
  	Flag        = info.ValidFlag;
    
    [i,j,bm]    = find(obj.Bitmask);
    
    tf                       = false(size(obj));
  	tf(sub2ind(obj.Sz,i,j))  = logical(bitget(bm,Flag.Id));
end