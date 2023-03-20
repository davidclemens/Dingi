function obj = ctranspose(obj)
% ctranspose  Transpose a bitmask
%   CTRANSPOSE returns the transpose of a bitmask.
%
%   Syntax
%     B = CTRANSPOSE(A)
%
%   Description
%     B = CTRANSPOSE(A)  returns the transpose of A, that is, interchanges the 
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
%   See also DATAKIT.BITMASK.TRANSPOSE, DATAKIT.BITMASK.PERMUTE, DATAKIT.BITMASK
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = DataKit.bitmask(ctranspose(obj.Bits));
end
