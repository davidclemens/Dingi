function obj = and(objA,objB)
% and  Combine bitflags with logical AND
%   AND combines bitflags with the flagwise logical AND operation.
%
%   Syntax
%     C = AND(A,B)
%
%   Description
%     C = AND(A,B)  performs a flagwise logical AND of bitflags A and B and
%       returns a bitflag array containing elements with each flag set
%       accordingly. A flag of an elemnt in the output array is set to high if
%       both A and B contain the same high flag for the same element. Otherwise
%       the flag is set to low.
%
%   Example(s)
%     C = AND(DataKit.bitflag(7),DataKit.bitflag(3)  returns C =
%       DataKit.bitflag(3) or ......11 (where . is low and 1 is high).
%
%
%   Input Arguments
%     A,B - Bitflags
%       DataKit.bitflag array
%         Input bitflags, specified as scalar, vector, matrix or 
%         multidimensional DataKit.bitflag arrays. Inputs A and B must either be 
%         the same size or have sizes that are compatible (for example, A is an 
%         M-by-N matrix and B is a scalar or 1-by-N row vector).
%
%
%   Output Arguments
%     C - Output bitflag
%       DataKit.bitflag array
%         Output bitflag, returned as a scalar, vector, matrix or 
%         multidimensional DataKit.bitflag array.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DataKit.bitflag
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    assert(strcmp(objA.EnumerationClassName,objB.EnumerationClassName),...
        'DataKit:bitflag:and:EnumerationClassMissmatch',...
        'The enumeration class names have to match.')
    
    bitsC   = and@DataKit.bitmask(objA,objB);
    
    obj     = DataKit.bitflag(objA.EnumerationClassName,bitsC.Bits);    
end
