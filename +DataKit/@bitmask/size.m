function varargout = size(obj,varargin)
% size  Short description of the function/method
%   SIZE long description goes here. It can hold multiple
%   lines as it can go into lots of detail.
%
%   Syntax
%     sz = SIZE(bm)
%     szdim = SIZE(bm,dim)
%     [m,n] = SIZE(bm)
%     [sz1,...,szN] = SIZE(bm)
%
%   Description
%     sz = SIZE(bm)  Returns a row vector whose elements contain the length of 
%       the corresponding dimension of bitmask bm. For example, if bm is a
%       3-by-4 bitmask, then size(bm) returns the vector [3 4]. The length of sz
%       is ndims(bm).
%     szdim = SIZE(bm,dim)  Returns the length of dimension dim.
%     [m,n] = SIZE(bm)  Returns the number of rows and columns when bm is a 2D
%       bitmask matrix.
%     [sz1,...,szN] = SIZE(bm)  Returns the length of each dimension of bm
%       separately.
%
%   Example(s)
%     sz = SIZE(DataKit.bitmask(3))  returns sz = [1 1]
%     sz = SIZE(DataKit.bitmask([3;2]))  returns sz = [2 1]
%     szdim = SIZE(DataKit.bitmask(ones(5,3),2)  returns szdim = 3
%     [m,n] = SIZE(DataKit.bitmask(ones(5,3)))  returns m = 5 & n = 3
%     [a,b,c,d] = SIZE(DataKit.bitmask(ones(5,3,1,4)))  returns a = 5, b = 3, 
%       c = 1 & d = 4
%
%
%   Input Arguments
%     bm - Bitmask
%       DataKit.bitmask
%         Input1 long description, that can also span multiple lines, since it
%         really goes into detail.
%
%     dim - Queried dimension
%       positive integer scalar
%         Queried dimension, specified as a positive integer scalar. SIZE 
%         returns the length of dimension dim of bm.
%
%
%   Output Arguments
%     sz - Bitmask size
%       row vector of nonnegative integers
%         Bitmask size, returned as a row vector of nonnegative integers. Each
%         element of the vector represents the length of the corresponding
%         dimension of bm. If bm is a scalar, then sz is the row vector [1 1].
%
%     szdim -  Length of specified dimension
%       nonnegative integer scalar
%         Length of specified dimension, returned as a nonnegative integer
%         scalar.
%
%     m -  Number of rows
%       nonnegative integer scalar
%         Number of rows, returned as a nonnegative integer scalar when bm is a
%         2D bitmask matrix.
%
%     n -  Number of columns
%       nonnegative integer scalar
%         Number of columns, returned as a nonnegative integer scalar when bm is
%         a 2D bitmask matrix.
%
%     sz1,...,szN -  Dimension lengths
%       nonnegative integer scalars
%         Dimension lengths, returned as nonnegative integer scalars. When the
%         specified number of output arguments is equal to ndims(bm), then each
%         argument is the length of the corresponding dimension of bm. If more
%         than ndims(bm) output arguments are specified, then the extra output
%         arguments are set to 1. For example, for a bitmask bm with size [4 5],
%         [sz1,sz2,sz3] = size(bm) returns sz1 = 4, sz2 = 5 & sz3 = 1.
%         If fewer than ndims(bm) output arguments are specified, then all
%         remaining dimension lengths are collapsed into the last argument in
%         the list. For example, if bm is a 3-D bitmask array with size [3 4 5],
%         then [sz1,sz2] = size(bm) returns sz1 = 3 & sz2 = 20.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITMASK
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    narginchk(1,2)
    
    nDims   = ndims(obj.Bits);
    
    sz = size(obj.Bits,varargin{:});
    
    if nargout <= 1
        varargout{1} = sz;
    elseif nargout >= 2
        if nargout < nDims
            varargout = num2cell([sz(1:nargout - 1),prod(sz(nargout:end))]);
        else
            varargout = num2cell([sz,ones(1,nargout - nDims)]);
        end
    end
end
