function varargout = ndfind(X)
% ndfind  Simplified find for multidimensional subscripts
%   NDFIND is a simplified implementation of the builtin find function, but
%   returns n-dimensional subscripts.
%
%   Syntax
%     [v,dim1Sub,...,dimNSub] = NDFIND(X)
%
%   Description
%     [v,dim1Sub,...,dimNSub] = NDFIND(X) returns the value v all non-zero
%       elements in X and the corresponding n-dimensional subscripts
%       dim1Sub,...,dimNSub.
%
%   Example(s)
%
%
%   Input Arguments
%     X - Input array
%       data type restriction 1 | data type restriction 2
%         Input array, specified as a scalar, vector, matrix, or
%         multidimensional array. If X is an empty array or has no nonzero 
%         elements, then v and dim1Sub,...,dimNSub are empty arrays.
%
%   Output Arguments
%     v - Nonzero elements of X
%       vector
%         Nonzero elements of X, returned as a vector.
%
%     dim1Sub,...,dimNSub - N-dimensional subscrips
%       vector
%         N-dimensional subscripts, returned as a vector. Together, 
%         dim1Sub,...,dimNSub specify the X(dim1Sub,...,dimNSub) subscripts
%         corresponding to the nonzero elements in X.
%
%
%   Name-Value Pair Arguments
%
%
%   See also FIND
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    if isempty(X)
        varargout = cell(1,nargout);
        return
    end
    
    sz              = size(X);
    nDims           = ndims(X);
    
    nargoutchk(1,1 + nDims)
    
    [i,j,v]         = find(X);
    i               = reshape(i,[],1);
    j               = reshape(j,[],1);
    v               = reshape(v,[],1);
    
    if nDims > 2
        % If X is a multidimensional array with N > 2, then j is a linear
        % index over the N-1 trailing dimensions of obj.Bits. This preserves the
        % relation X(i(ii),j(ii)) == v(ii).
        subs            = cell(1,nDims);
        subs{1}         = i;
        [subs{2:end}]   = ind2sub(sz(2:end),j);
    else
        subs = {i,j};
    end
    
    varargout{1}    = v;
    varargout       = cat(2,varargout,subs);
end