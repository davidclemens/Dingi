function storageType = minStorageType(obj,A)

    if any(A(:) > intmax('uint64'))
        error('Dingi:DataKit:bitmask:array2storagetype:invalidNumberOfInputs',...
        'Invalid number of inputs.')
    end
    
    storageType = obj.validStorageTypeNames{find(nextpow2(max(cat(1,uint64(0),uint64(A(:)))) + 1) <= 2.^(3:6),1)};
end