function obj = permute(obj,order)
% permute  Rearrange dimensions of a bitmask
%   PERMUTE rearranges the dimensions of a bitmask.
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
%     A - input bitmask
%       DataKit.bitmask
%         Input bitmask specified as a DataKit.bitmask.
%
%     order - dimension order
%       integer vector
%         Dimension order, specified as a vector of unique, real, positive
%         integer values.
%
%
%   Output Arguments
%     B - output bitmask
%       DataKit.bitmask
%         Output bitmask returned as a DataKit.bitmask.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITMASK.TRANSPOSE, DATAKIT.BITMASK.CTRANSPOSE, DATAKIT.BITMASK
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = DataKit.bitmask(permute(obj.Bits,order));
end

