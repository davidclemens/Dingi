function varargout = createEvalTreeNode(tokens,varargin)
% createEvalTreeNode  Recursively create evaluation tree from tokens
%   CREATEEVALTREENODE transforms the tokens from an expression into a
%   recursive parse tree, following order of operations. Operations can include
%   binary (e.g. '3 + 4'), implicit (e.g. '3 kg') or unary (e.g. '-3'). The
%   general strategy is as follows:
%     1. Get the left side of an operator
%     2. If no tokens are left, return the final left side
%     3. Get the operator
%     4. Use recursion to create the tree, starting at the token on the right
%        side of the operator (starting at step 1)
%        4.1. If the recursive call encounters an operator with lower or equal
%             priority to step 2, exit the recursion.
%     5. Combine the left side, the operator and the right side into a new left
%        side.
%     6. Continue from step 2.
%
%   Syntax
%     node = CREATEEVALTREENODE(tokens)
%     node = CREATEEVALTREENODE(__,Name,Value)
%     [node,index] = CREATEEVALTREENODE(__)
%
%   Description
%     node = CREATEEVALTREENODE(tokens)  
%     node = CREATEEVALTREENODE(__,Name,Value)  Add additional options
%       specified by one or more Name,Value pair arguments.
%     [node,index] = CREATEEVALTREENODE(__)  Additionally return an index.
%
%   Example(s)
%
%
%   Input Arguments
%     tokens - Tokens
%       struct array
%         Input tokens specified as struct array as returned by
%         DataKit.Units.Parser.parser.tokenize.
%
%
%   Output Arguments
%     node - Eval tree node
%       DataKit.Units.Parser.evalTreeNode
%         Evaluation tree node specified as a
%         DataKit.Units.Parser.evalTreeNode instance.
%
%     index - Index
%       positive integer scalar
%         Output index returned as a positive integer scalar. This output is
%         used in the recursive context.
%
%
%   Name-Value Pair Arguments
%     Index - Token index
%       positive integer scalar
%         The current token index specified as a positive integer scalar <=
%         numel(tokens).
%
%     Depth - Sub operation depth
%       positive integer scalar
%         The current sub operation depth specified as a positive integer
%         scalar. This parameter is used in the recursive context.
%
%     PreviousOperator - Previous operator
%       char
%         The last operator encountered, specified as a char row vector. This
%         parameter is used in the recursive context.
%
%     OperatorPriority - Operator priority definition
%       containers.Map
%         Operator priority definition specified as a container.Map instance
%         with operators (e.g. '^', '+', etc.) as keys and integer scalars as
%         values, representing the operator priority (higher value = higher
%         priority).
%
%
%   See also DATAKIT.UNITS.PARSER.PARSER
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import internal.stats.parseArgs
    import DataKit.Units.Parser.evalTreeNode
    import DataKit.Units.Parser.parser.createEvalTreeNode

    % Parse Name-Value pairs
    optionName          = {'Index','Depth','PreviousOperator','OperatorPriority'}; % valid options (Name)
    optionDefaultValue  = {1,1,[],containers.Map('KeyType','char','ValueType','double')}; % default value (Value)
    [index,...
     depth,...
     previousOperator,...
     operatorPriority...
        ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    % Initialize
    result = [];

    while true
        token       = tokens(index);
        tokenType   = token.Type;
        tokenText   = token.Text;

        if strcmp(tokenType,'OP')
            switch tokenText
                case ')'
                    if isempty(previousOperator)
                        error('Dingi:DataKit:Units:parser:parser:createEvalTree:InvalidClosingParenthesis',...
                            'Found in token.')
                    elseif strcmp(previousOperator,'(')
                        % Close parenthetical group
                        varargout{1} = result;
                        varargout{2} = index;
                        break
                    else
                        % Parenthetical group ending, but the sub-operations need to be closed within
                        % the group
                        varargout{1} = result;
                        varargout{2} = index - 1;
                        break
                    end
                case '('
                    % Gather parenthesis group
                    [right,index] = createEvalTreeNode(tokens,...
                        'Index',                index + 1,...
                        'Depth',                0,...
                        'PreviousOperator',     tokenText,...
                        'OperatorPriority',     operatorPriority);
                    if ~isempty(result)
                        % Implicit operation with a parenthical group, e.g. '3 (kg ^ 2)'
                        result = evalTreeNode(...
                            'Left',     result,...
                            'Right',    right);
                    else
                        % Get first token
                        result = right;
                    end

                case operatorPriority.keys
                    if ~isempty(result)
                        % Equal priority operators are gropued in a left-to-right order, unless they're
                        % exponentiation, in which case they're grouped right-to-left. This allows to
                        % get the expected behavior for multiple exponents, e.g.:
                        %   (2^3^4)  --> (2^(3^4))
                        %   (2 * 3 / 4) --> ((2 * 3) / 4)
                        if operatorPriority(token.Text) <= getFromMapWithDefault(operatorPriority,previousOperator,-1) && ...
                           ~strcmp(token.Text,'^')
                            % Previous operator is higher priority. Therefore, end previous binary operation
                            varargout{1} = result;
                            varargout{2} = index - 1;
                            break
                        end

                        % Get the right side of the binary operation
                        [right,index] = createEvalTreeNode(tokens,...
                            'Index',                index + 1,...
                            'Depth',                depth + 1,...
                            'PreviousOperator',     tokenText,...
                            'OperatorPriority',     operatorPriority);

                        result = evalTreeNode(...
                            'Left',     result,...
                            'Operator',	token,...
                            'Right',    right);
                    else
                        % Unary operator
                        [right,index] = createEvalTreeNode(tokens,...
                            'Index',                index + 1,...
                            'Depth',                depth + 1,...
                            'PreviousOperator',     'unary',...
                            'OperatorPriority',     operatorPriority);

                        result = evalTreeNode(...
                            'Left',     right,...
                            'Operator',	token);
                    end
            end
        elseif strcmp(tokenType,'NUMBER') || strcmp(tokenType,'NAME')
            if ~isempty(result)
                % Token with an implicit operation, e.g. '1 kg'
                if operatorPriority('') <= getFromMapWithDefault(operatorPriority,previousOperator,-1)
                    % Previous operator has higher priority than implicit. Therefore, end previous
                    % binary operation
                    varargout{1} = result;
                    varargout{2} = index - 1;
                    break
                end

                [right,index] = createEvalTreeNode(tokens,...
                    'Index',                index,...
                    'Depth',                depth + 1,...
                    'PreviousOperator',     '',...
                    'OperatorPriority',     operatorPriority);

                result = evalTreeNode(...
                    'Left',     result,...
                    'Right',    right);
            else
                % Get first token
                result = evalTreeNode(...
                    'Left',     token);
            end
        end

        if index == numel(tokens)
            if strcmp(previousOperator,'(')
                error('Dingi:DataKit:Units:parser:parser:createEvalTree:UnclosedParentheses',...
                    '')
            end

            if depth > 1 || ~isempty(previousOperator)
                varargout{1} = result;
                varargout{2} = index;
                break
            else
                varargout{1} = result;
                break
            end
        end

        % Increment index
        index = index + 1;
    end

    function p = getFromMapWithDefault(map,key,default)
        if ischar(key) && ismember(key,map.keys)
            p = map(key);
        else
            p = default;
        end
    end
end
