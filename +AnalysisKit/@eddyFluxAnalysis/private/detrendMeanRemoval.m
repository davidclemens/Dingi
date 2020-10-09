function y = detrendMeanRemoval(x)
% DETRENDMEANREMOVAL

    y = x - nanmean(x,1);
end