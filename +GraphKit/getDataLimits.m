function lim = getDataLimits(h,xy)
    nax             = numel(xy);
    ax              = upper(cellstr(xy'));
    h               = h(:);
    tmpData         = cell(nax,1);
    lim             = cell(nax,1);
    isPlaceholder  = arrayfun(@(o) isa(o,'matlab.graphics.GraphicsPlaceholder'),h);
    for iiax = 1:nax
        % Extract axis data
        tmpData{iiax}	= get(h(~isPlaceholder),...
                            {[ax{iiax},'Data']});
        % Append NaN to make sure that data is not empty
        tmpData{iiax}(end + 1) = {NaN};
        
        % Calculate limits
        lim{iiax}   	= [nanmin([tmpData{iiax}{:}]),nanmax([tmpData{iiax}{:}])];
    end
end