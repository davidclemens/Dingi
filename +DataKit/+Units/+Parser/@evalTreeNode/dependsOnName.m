function tf = dependsOnName(obj)
% dependsOnName  Determine if node depends on any NAME token
%   DEPENDSONNAME determines if an evaluation node depends on any token of type
%   'NAME'.
%
%   Syntax
%     tf = DEPENDSONNAME(obj)
%
%   Description
%     tf = DEPENDSONNAME(obj)  returns logical 1 (true) if evaluation tree node
%       obj depends on a token of type 'NAME'.
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
%     tf - Logical output
%       logical scalar
%         Logical output, returned as true, if the node depends on any token of
%         type 'NAME'.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.UNITS.PARSER.EVALTREENODE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    if ~isempty(obj.Right)
        % Binary or implicit operator

        leftDependsOnName = obj.Left.dependsOnName;
        rightDependsOnName = obj.Right.dependsOnName;

        tf = leftDependsOnName || rightDependsOnName;
    elseif ~isempty(obj.Operator)
        % Unary operator

        tf = obj.Left.dependsOnName;
    else
        % Single value
        tf = strcmp(obj.Left.Type,'NAME');
    end
end

