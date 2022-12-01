function C = char(obj,varargin)
% char  Evaluation tree node to character array
%   CHAR converts an evaluation tree node into a char row vector. With multiple
%   nested nodes, this becomes a recursive algorithm.
%
%   Syntax
%     C = CHAR(obj)
%     C = CHAR(__,Name,Value)
%
%   Description
%     C = CHAR(obj)  Convert evalTreeNode obj into char row vector C.
%     C = CHAR(__,Name,Value)  Add additional options specified by one or more
%       Name,Value pair arguments.
%
%   Example(s)
%
%
%   Input Arguments
%     obj - Evaluation tree node
%       DataKit.Units.Parser.evalTreeNode
%         Evalutaion tree node specified as a DataKit.Units.Parser.evalTreeNode
%         instance.
%
%
%   Output Arguments
%     C - Output vector 
%       char row vector
%         The output vector specified as a char row vector.
%
%
%   Name-Value Pair Arguments
%     DivisionAsNegativeExponent - Express division as negative exponent
%       false (default) | true | 0 | 1
%         If true, express division as negative exponent. Defaults to false.
%
%
%   See also DATAKIT.UNITS.PARSER.EVALTREENODE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import internal.stats.parseArgs

    % Parse Name-Value pairs
    optionName          = {'DivisionAsNegativeExponent'}; % valid options (Name)
    optionDefaultValue  = {false}; % default value (Value)
    [divisionAsNegativeExponent...
     ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    if ~isempty(obj.Right)
        % Node has a right side (Cases 1 or 3)
        
        % Start with the left side
        comps = {char(obj.Left,'DivideAsNegativeExponent',divisionAsNegativeExponent)};
        
        % Append the operator, if existent (Case 1)
        if ~isempty(obj.Operator)
            if divisionAsNegativeExponent
                switch obj.Operator.Text
                    case '/'
                        comps = cat(2,comps,{['* (',char(obj.Right,'DivideAsNegativeExponent',divisionAsNegativeExponent),' ^ (- 1))']});
                    otherwise
                        comps = cat(2,comps,{obj.Operator.Text},{char(obj.Right,'DivideAsNegativeExponent',divisionAsNegativeExponent)});
                end
            else
                comps = cat(2,comps,{obj.Operator.Text},{char(obj.Right,'DivideAsNegativeExponent',divisionAsNegativeExponent)});
            end
        else
            % Finally, append the right side (Cases 1 or 3)
            comps = cat(2,comps,{char(obj.Right,'DivideAsNegativeExponent',divisionAsNegativeExponent)});
        end
    elseif ~isempty(obj.Operator)
        % Node has no right side but an operator (Case 2)
        comps = cat(2,{obj.Operator.Text},char(obj.Left,'DivideAsNegativeExponent',divisionAsNegativeExponent));
    else
        % Node has no operator and no right side (Case 4)
        C = obj.Left.Text;
        return
    end
    
    % Join all with whitspace and encapsulated in parenthesis.
    C = cat(2,'(',strjoin(comps,' '),')');
end
