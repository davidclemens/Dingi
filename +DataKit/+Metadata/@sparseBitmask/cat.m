function obj = cat(dim,varargin)

    import DataKit.Metadata.sparseBitmask
    
    isaSparseBitmask = cellfun(@(in) isa(in,'DataKit.Metadata.sparseBitmask'),varargin);
    if ~all(isaSparseBitmask)
        error('Dingi:DataKit:Metadata:sparseBitmask:cat:invalidInputType',...
            'All inputs must be sparse bitmasks')
    end
    
    % extract all bitmasks
    bitmasks    = cellfun(@(in) in.Bitmask,varargin,'un',0);
    
    % concatenate the bitmask
    bitmask     = cat(dim,bitmasks{:});
    
    % create new sparse bitmask object
    obj         = sparseBitmask(bitmask);
end