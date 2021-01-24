function obj = cell2enum(C,classname)
    
    sz  = size(C);
    obj = reshape(cat(1,cellfun(@(c) eval([classname,'.',c]),C,'un',1)),sz);
end