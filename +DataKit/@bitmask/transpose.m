function obj = transpose(obj)
% transpose  Transpose a bitmask
%   TRANSPOSE returns the transpose of a bitmask.
%
%   Syntax
%     B = TRANSPOSE(A)
%
%   Description
%     B = TRANSPOSE(A)  returns the transpose of A, that is, interchanges the 
%       row and column index for each element.
%
%   Example(s)
%
%
%   Input Arguments
%     A - input bitmask
%       DataKit.bitmask
%         Input bitmask specified as a DataKit.bitmask.
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
%   See also DATAKIT.BITMASK.CTRANSPOSE, DATAKIT.BITMASK.PERMUTE, DATAKIT.BITMASK
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = DataKit.bitmask(transpose(obj.Bits));
end
