function [y,meanValue] = detrendMeanRemoval(x)
% DETRENDMEANREMOVAL

    meanValue = nanmean(x,1);
    y = x - meanValue;
end