function obj = cat(dim,varargin)
    
    uClassNames = unique(cellfun(@(in) class(in),varargin,'un',0));
    
    if numel(uClassNames) ~= 1
        error('Dingi:DataKit:bitmask:cat:differingInputTypes',...
            'All inputs must be the same type.')
    end
    
    obj     = varargin{1};
    
    % extract all bitmasks
    bms    = cellfun(@(in) in.Bits,varargin,'un',0);
    
    % concatenate the bitmask
    bm     = cat(dim,bms{:});
    
    % create new bitmask object
    obj.Bits = bm;
end