function C = toChar(obj,varargin)
% toChar  Parsing result as character array
%   TOCHAR return the parsing result as a character array.
%
%   Syntax
%     C = TOCHAR(obj)
%     C = TOCHAR(__,Name,Value)
%
%   Description
%     C = TOCHAR(obj)  Description of syntax 1.
%     C = TOCHAR(__,Name,Value)  Add additional options specified by one or more
%       Name,Value pair arguments.
%
%   Example(s)
%     C = TOCHAR(obj)  returns X
%     C = TOCHAR(__,Name,Value)
%
%
%   Input Arguments
%     obj - Parser
%       DataKit.Units.Parser.parser
%         Parser specified as a DataKit.Units.Parser.parser instance.
%
%
%   Output Arguments
%     C - Parsing result
%       char row vector
%         The parsing result specified as a char row vector.
%
%
%   Name-Value Pair Arguments
%     DivisionAsNegativeExponent - Express division as negative exponent
%       false (default) | true | 0 | 1
%         If true, express division as negative exponent. Defaults to false.
%
%
%   See also DATAKIT.UNITS.PARSER.PARSER
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%


    import internal.stats.parseArgs

    % Parse Name-Value pairs
    optionName          = {'DivisionAsNegativeExponent'}; % valid options (Name)
    optionDefaultValue  = {false}; % default value (Value)
    [divisionAsNegativeExponent...
     ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
    switch obj.Type
        case 'Expression'
            C = char(obj.Tree,...
                'DivisionAsNegativeExponent',     divisionAsNegativeExponent);
            
            % Remove the redundant outer brackets
            C = C(2:end - 1);
    end
end
