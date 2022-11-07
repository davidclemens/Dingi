function ind = startend2ind(startend)
% startend2ind  Convert start-end index pairs to indices
%   STARTEND2IND converts multiple start-end index pairs to a vector of linear
%   indices.

    ind = arrayfun(@colon,startend(:,1),startend(:,2),'un',0);
    ind = cat(2,ind{:});
end
