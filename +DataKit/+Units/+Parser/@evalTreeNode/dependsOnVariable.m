function tf = dependsOnVariable(obj)
% dependsOnVariable  Determine if node depends on any VAR token
%   DEPENDSONVARIABLE determines if an evaluation node depends on any token of 
%   type 'NAME' and exact type 'VAR'.
%
%   Syntax
%     tf = DEPENDSONVARIABLE(obj)
%
%   Description
%     tf = DEPENDSONVARIABLE(obj)  returns logical 1 (true) if evaluation tree 
%       node obj depends on a token of type 'NAME' and exact type 'VAR'.
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
%         type 'NAME' and exact type 'VAR'.
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

        leftDependsOnVariable = obj.Left.dependsOnVariable;
        rightDependsOnVariable = obj.Right.dependsOnVariable;

        tf = leftDependsOnVariable || rightDependsOnVariable;
    elseif ~isempty(obj.Operator)
        % Unary operator

        tf = obj.Left.dependsOnVariable;
    else
        % Single value
        tf = strcmp(obj.Left.Type,'NAME') && strcmp(obj.Left.ExactType,'VAR');
    end
end

