function lim = getDataLimits(h,xy)
    nax             = numel(xy);
    ax              = upper(cellstr(xy'));
    h               = h(:);
    tmpData         = cell(nax,1);
    lim             = cell(nax,1);
    for iiax = 1:nax
        tmpData{iiax}	= get(h(~strcmp('matlab.graphics.GraphicsPlaceholder',arrayfun(@class,h,'un',0))),...
                            {[ax{iiax},'Data']});
        lim{iiax}   	= [nanmin([tmpData{iiax}{:}]),nanmax([tmpData{iiax}{:}])];
    end
end