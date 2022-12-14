function tf = isNumeric(obj)
% isNumeric  Determine if node depends only on NUMBER tokens
%   ISNUMERIC determines if an evaluation node depends only on tokens of type
%   'NUMBER'.
%
%   Syntax
%     tf = ISNUMERIC(obj)
%
%   Description
%     tf = ISNUMERIC(obj)  returns logical 1 (true) if evaluation tree node
%       obj depends only on tokens of type 'NUMBER'.
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
%         Logical output, returned as true, if the node depends only on tokens
%         of type 'NUMBER'
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

        leftIsNumeric = obj.Left.isNumeric;
        rightIsNumeric = obj.Right.isNumeric;

        tf = leftIsNumeric && rightIsNumeric;
    elseif ~isempty(obj.Operator)
        % Unary operator

        tf = obj.Left.isNumeric;
    else
        % Single value
        tf = strcmp(obj.Left.Type,'NUMBER');
    end
end

