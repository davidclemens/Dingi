function tf = isBit(obj,bit)
% isBit  Tests which elements of a bitmask have a bit enabled
%   ISBIT tests, which elements of a bitmask have bit(s) bit enabled.
%   Returns as a logical array.
%
%   Syntax
%     tf = ISBIT(obj,bit)
%
%   Description
%     tf = ISBIT(obj,bit) returns a logical array of the same shape as the
%       bitmask obj set to true for elements of the bitmask where bit(s)
%       bit are enabled.
%
%   Example(s)
%     tf = ISBIT(obj,3) returns the logical array tf with all elements set
%       to true where bitmask obj has bit 3 enabled.
%     tf = ISBIT(obj,[3,8]) returns the logical array tf with all elements 
%       set to true where bitmask obj has bit 3 OR 8 enabled.
%
%
%   Input Arguments
%     obj - DataKit.bitmask instance
%       DataKit.bitmask
%         A DataKit.bitmask instance.
%
%     bit - Bit position
%       integer | integer array
%         Bit position which should be tested, specified as an integer or 
%         integer array. The values of bit must be between 1 (the least 
%         significant bit) and 64. If it exceeds this limit, it is ignored.
%         If bit is not scalar, all elements in bit are tested and combined
%         with the logical OR operator.
%
%
%   Output Arguments
%     tf - Logical array
%       logical
%         Logical array set to true where bitmask obj has bit(s) bit
%         enabled and false otherwise.
%
%
%   Name-Value Pair Arguments
%
%
%   See also BITMASK
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    import DebuggerKit.Debugger.printDebugMessage
    import DataKit.ndfind
    
    if isempty(bit)
        error('Dingi:DataKit:bitmask:isBit:invalidEmptyBit',...
            'Bit can''t be empty.')
    end
    
    sz      = obj.Size;
    nDims   = ndims(obj.Bits);
    
    bitExceedingStorageType     = bit > obj.StorageType;
    bitExceedingMaxStorageType  = bit > max(obj.validStorageTypes);
    
    if any(bitExceedingMaxStorageType)
        printDebugMessage('Dingi:DataKit:bitmask:isBit:bitExceedsMaxStorageType',...
            'Warning','A requested bit index (%u) exceeds the maximum storage type (%u). It is ignored.',bit(find(bitExceedingMaxStorageType,1)),max(obj.validStorageTypes))
    end
    
    % Find elements with set flags
    subs            = cell(1,nDims);
    [v,subs{:}]     = ndfind(obj.Bits);
    
    % Create logical array
    tf                       = false(sz);
    
    for bb = 1:numel(bit)
        if ~bitExceedingStorageType(bb)
            tf(sub2ind(sz,subs{:}))  = tf(sub2ind(sz,subs{:})) | logical(bitget(v,bit(bb)));
        end
    end
end