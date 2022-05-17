function [C,ia,ic] = unique(obj,varargin)

    classname   = class(obj);
    name        = cellstr(obj);
    
    [tmp,ia,ic] = unique(name,varargin{:});
    
    % Convert to original class
    C   = eval([classname,'(tmp)']);
end