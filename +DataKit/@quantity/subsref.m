function varargout = subsref(obj,S)
% subsref  Subscripted reference for a quantity
%   SUBSREF defines the subscripted reference behaviour for a DataKit.quantity
%   array.
%
%   Syntax
%     q = SUBSREF(Q,S)
%
%   Description
%     q = SUBSREF(Q,S) is called for the syntax Q(i,j,...) when Q is a
%       DataKit.quantity. S is a structure array.
%
%     q = Q(i,j,...,n) returns a quantity q that contains a subset of the
%     quantity Q. i,j,...,n  are positive integers, vectors of positive
%     integers or logical vectors. q contains the same values, uncertainty and
%     flags as Q, subsetted for i,j,...,n.
%
%   Example(s)
%     q = Q(3) returns quantity q that contains the subset of quantity Q at
%       linear index 3.
%     q = Q(3,4) returns quantity q that contains the subset of quantity Q at
%       subscript [3,4].       
%
%
%   Input Arguments
%     Q - Input quantity
%       DataKit.quantity array
%         The input quantity that is referenced
%
%     S - Subscript structure
%       struct array
%         Subscript structure array with the fields:
%           type: Character vector containing '()', '{}', or '.' specifying the
%                 subscript type.
%           subs: Cell array or character vector containing the actual
%                 subscripts.
%
%
%   Output Arguments
%     q - Subset quantity
%       DataKit.quantity array
%         The subset of quantity array Q after subscripted referencing, returned
%         as a DataKit.quantity array.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DataKit.quantity
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    switch S(1).type
        case '()'
            [varargout{1:nargout}] = DataKit.quantity(...
                subsref(double(obj),S(1)),...
                subsref(obj.Sigma,S(1)),...
                subsref(obj.Flag,S(1)));
        otherwise
            [varargout{1:nargout}] = subsref@double(obj,S);
    end
end
