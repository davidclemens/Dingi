function tf = isFlag(obj,flag)
% isFlag  Tests which elements of a bitflag have a flag enabled
%   ISFLAG tests, which elements of a bitflag have flag(s) flag enabled.
%   Returns as a logical array.
%
%   Syntax
%     tf = ISFLAG(obj,flag)
%
%   Description
%     tf = ISFLAG(obj,flag) returns a logical array of the same shape as the
%       bitflag obj set to true for elements of the bitflag where flag(s)
%       flag are enabled.
%
%   Example(s)
%     tf = ISFLAG(obj,3) returns the logical array tf with all elements set
%       to true where bitflag obj has flagId 3 enabled.
%     tf = ISFLAG(obj,'FlagName') returns the logical array tf with all 
%       elements set to true where bitflag obj has flag 'FlagName' enabled.
%     tf = ISFLAG(obj,{'FlagNameA','FlagNameB'}) returns the logical array 
%       tf with all elements set to true where bitflag obj has flag
%       'FlagNameA' OR 'FlagNameB' enabled.
%
%
%   Input Arguments
%     obj - DataKit.bitflag instance
%       DataKit.bitflag
%         A DataKit.bitflag instance.
%
%     flag - Flag to be tested
%       char | cellstr | numeric | enumeration
%         Flag which should be tested, specified as a scalar or vector of type
%         char, cellstr, numeric or the specified enumeration class. Char &
%         cellstr are checked against the enumeration member names and numeric
%         values are checked against the enumeration member ids. Only valid
%         flags are allowed. If flag is not scalar, all elements in flag
%         are tested and combined with the logical OR operator.
%
%
%   Output Arguments
%     tf - Logical array
%       logical
%         Logical array set to true where bitflag obj has flag(s) flag
%         enabled and false otherwise.
%
%
%   Name-Value Pair Arguments
%
%
%   See also BITFLAG
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    flagId  = obj.validateFlag(obj.EnumerationClassName,flag);
    
    tf      = obj.isBit(flagId);
end