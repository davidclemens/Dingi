function tf = dependsOnDimension(obj)
% dependsOnDimension  Determine if node depends on any DIM token
%   DEPENDSONDIMENSION determines if an evaluation node depends on any token of type
%   'NAME' and exact type 'DIM'.
%
%   Syntax
%     tf = DEPENDSONDIMENSION(obj)
%
%   Description
%     tf = DEPENDSONDIMENSION(obj)  returns logical 1 (true) if evaluation tree 
%       node obj depends on a token of type 'NAME' and exact type 'DIM'.
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
%         type 'NAME' and exact type 'DIM'.
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

        leftDependsOnDimension = obj.Left.dependsOnDimension;
        rightDependsOnDimension = obj.Right.dependsOnDimension;

        tf = leftDependsOnDimension || rightDependsOnDimension;
    elseif ~isempty(obj.Operator)
        % Unary operator

        tf = obj.Left.dependsOnDimension;
    else
        % Single value
        tf = strcmp(obj.Left.Type,'NAME') && strcmp(obj.Left.ExactType,'DIM');
    end
end

