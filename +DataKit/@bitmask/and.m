function obj = and(objA,objB)
% and  Combine bitmask with logical AND
%   AND combines bitmasks with the bitwise logical AND operation.
%
%   Syntax
%     C = AND(A,B)
%
%   Description
%     C = AND(A,B)  performs a bitwise logical AND of bitmasks A and B and
%       returns a bitmask array containing elements with each bit set
%       accordingly. A bit of an elemnt in the output array is set to high if
%       both A and B contain the same high bit for the same element. Otherwise
%       the bit is set to low.
%
%   Example(s)
%     C = AND(DataKit.bitmask(7),DataKit.bitmask(3)  returns C =
%       DataKit.bitmask(3) or ......11 (where . is low and 1 is high).
%
%
%   Input Arguments
%     A,B - Bitmasks
%       DataKit.bitmask array
%         Input bitmasks, specified as scalar, vector, matrix or 
%         multidimensional DataKit.bitmask arrays. Inputs A and B must either be 
%         the same size or have sizes that are compatible (for example, A is an 
%         M-by-N matrix and B is a scalar or 1-by-N row vector).
%
%
%   Output Arguments
%     C - Output bitmask
%       DataKit.bitmask array
%         Output bitmask, returned as a scalar, vector, matrix or 
%         multidimensional DataKit.bitmask array.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DataKit.bitmask, DataKit.bitmask.or
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%


    storageTypeNames	= {objA.StorageTypeName;objB.StorageTypeName};
    [~,typeInd]         = ismember({objA.StorageTypeName;objB.StorageTypeName},objA.validStorageTypeNames);
    [~,castTypeInd]     = max(objA.validStorageTypes(typeInd));
    castType            = storageTypeNames{castTypeInd};
    
    if castTypeInd == 1
        objB = objB.changeStorageType(castType);
    end
    if castTypeInd == 2
        objA = objA.changeStorageType(castType);
    end
    bitsC   = bitand(objA.Bits,objB.Bits,castType);
    
    obj     = DataKit.bitmask(bitsC);    
end
