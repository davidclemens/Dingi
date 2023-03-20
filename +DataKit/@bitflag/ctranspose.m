function obj = ctranspose(objA)
% ctranspose  Transpose a bitflag
%   CTRANSPOSE returns the transpose of a bitflag.
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
%     A - input bitflag
%       DataKit.bitflag
%         Input bitflag specified as a DataKit.bitflag.
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
%   See also DATAKIT.BITFLAG.TRANSPOSE, DATAKIT.BITFLAG.PERMUTE, DATAKIT.BITFLAG
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = DataKit.bitflag(objA.EnumerationClassName,ctranspose(objA.Bits));
end
