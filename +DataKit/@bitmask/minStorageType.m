function storageType = minStorageType(obj,A)

    if any(A(:) > intmax('uint64'))
        error('Dingi:DataKit:bitmask:array2storagetype:invalidNumberOfInputs',...
        'Invalid number of inputs.')
    end
    
%     currentStorageType  = 2^(uint64(obj.StorageType)) - 1;
    currentMaxNumber    = uint64(max(obj.Bits(:)));
    minStorageType      = uint64(0);
    newDataStorageType  = uint64(A(:));
    storageType = obj.validStorageTypeNames{find(nextpow2(max(cat(1,minStorageType,currentMaxNumber,newDataStorageType)) + 1) <= 2.^(3:6),1)};
end