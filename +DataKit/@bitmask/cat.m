function obj = cat(dim,varargin)

    import DataKit.bitmask
    
    isaBitmask = cellfun(@(in) isa(in,'DataKit.bitmask'),varargin);
    if ~all(isaBitmask)
        error('Dingi:DataKit:bitmask:cat:invalidInputType',...
            'All inputs must be bitmasks')
    end
    
    % extract all bitmasks
    bitmasks    = cellfun(@(in) in.Bits,varargin,'un',0);
    
    % concatenate the bitmask
    bitmask     = cat(dim,bitmasks{:});
    
    % create new sparse bitmask object
    obj         = bitmask(bitmask);
end