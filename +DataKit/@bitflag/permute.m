function obj = permute(objA,order)
% permute  Rearrange dimensions of a bitflag
%   PERMUTE rearranges the dimensions of a bitflag.
%
%   Syntax
%     B = PERMUTE(A,order)
%
%   Description
%     B = PERMUTE(A,order)  rearranges the dimensions of A so that they are in
%       the order specified by the vector order. B has the same values of A but
%       the order of the subscripts needed to access any particular element is
%       rearranged as specified by order. All the elements of order must be
%       unique, real, positive, integer values.
%
%   Example(s)
%
%
%   Input Arguments
%     A - input bitflag
%       DataKit.bitflag
%         Input bitflag specified as a DataKit.bitflag.
%
%     order - dimension order
%       integer vector
%         Dimension order, specified as a vector of unique, real, positive
%         integer values.
%
%
%   Output Arguments
%     B - output bitflag
%       DataKit.bitflag
%         Output bitflag returned as a DataKit.bitflag.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITFLAG.TRANSPOSE, DATAKIT.BITFLAG.CTRANSPOSE, DATAKIT.BITFLAG
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = DataKit.bitflag(objA.EnumerationClassName,permute(objA.Bits,order));
end
