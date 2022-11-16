function obj = or(objA,objB)
% or  Combine bitflags with logical OR
%   OR combines bitflags with the flagwise logical OR operation.
%
%   Syntax
%     C = OR(A,B)
%
%   Description
%     C = OR(A,B)  performs a flagwise logical OR of bitflags A and B and
%       returns a bitflag array containing elements with each flag set
%       accordingly. A flag of an elemnt in the output array is set to high if
%       either A or B contain the same high flag for the same element. Otherwise
%       the flag is set to low.
%
%   Example(s)
%     C = OR(DataKit.bitflag(7),DataKit.bitflag(3)  returns C =
%       DataKit.bitflag(7) or .....111 (where . is low and 1 is high).
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
%   See also DataKit.bitflag, DataKit.bitflag.and
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    assert(strcmp(objA.EnumerationClassName,objB.EnumerationClassName),...
        'DataKit:bitflag:and:EnumerationClassMissmatch',...
        'The enumeration class names have to match.')
    
    bitsC   = or@DataKit.bitmask(objA,objB);
    
    obj     = DataKit.bitflag(objA.EnumerationClassName,bitsC.Bits);    
end
