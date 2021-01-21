function obj = cat(dim,varargin)

    import DataKit.Metadata.dataFlag
    
    isaDataFlag = cellfun(@(in) isa(in,'DataKit.Metadata.dataFlag'),varargin);
    if ~all(isaDataFlag)
        error('DataKit:Metadata:dataFlag:cat:invalidInputType',...
            'All inputs must be data flags')
    end
    
    % extract all bitmasks
    bitmasks    = cellfun(@(in) in.Bitmask,varargin,'un',0);
    
    % concatenate the bitmask
    bitmask     = cat(dim,bitmasks{:});
    
    % create new sparse bitmask object
    obj         = dataFlag(bitmask);
end