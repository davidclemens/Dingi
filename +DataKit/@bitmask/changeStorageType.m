function obj = changeStorageType(obj,newStorageTypeName)

    if intmax(newStorageTypeName) >= max(cat(1,zeros(1,newStorageTypeName),obj.Bits_(:)))
        obj.Bits_               = cast(obj.Bits_,newStorageTypeName);
        obj.StorageTypeName_    = newStorageTypeName;
        obj.StorageType_        = str2double(subsref(regexp(newStorageTypeName,'uint(\d{1,2})','tokens'),substruct('{}',{':'},'{}',{':'})));
    else
        % Do not typecast as data would be lost otherwise
        warning('Dingi:DataKit:bitmask:changeStorageType:dataLoss',...
            'Storage type was not changed from ''%s'' to ''%s'' in order to not loose data.',obj.StorageTypeName,newStorageTypeName)
    end
end