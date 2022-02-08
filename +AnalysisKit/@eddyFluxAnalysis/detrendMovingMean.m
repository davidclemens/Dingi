function [y,meanValue] = detrendMovingMean(x,window)
% DETRENDMOVINGMEAN

    
    meanValue	= NaN(size(x));
    for ii = 1:size(x,3)
        meanValue(:,:,ii) = reshape(movmean(reshape(x(:,:,ii),[],1),window,'omitnan',...
                                'Endpoints',        'fill'),size(x,1),size(x,2),1);
    end
    y = x - meanValue;
end