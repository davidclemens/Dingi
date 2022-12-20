function tf = isMultiplicative(obj)
% isMultiplicative  Determines if node is multiplicative
%   ISMULTIPLICATIVE determines if an evaluation tree node is multiplicative
%   with respect to tokens of type 'NAME' that it depends on.
%
%   Syntax
%     tf = ISMULTIPLICATIVE(obj)
%
%   Description
%     tf = ISMULTIPLICATIVE(obj)  returns logical 1 (true) if evaluation tree 
%       node obj is multiplicative with respect to all nodes of type 'NAME' it
%       depends on.
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
%         Logical output, returned as true, if the node is multiplicative with
%         respect to all nodes of type 'NAME' that it depends on.
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
        if ~isempty(obj.Operator)
            opText = obj.Operator.Text;
        else
            opText = '';
        end
        leftIsMultiplicative        = obj.Left.isMultiplicative;
        leftDependsOnName           = obj.Left.dependsOnName;
        rightIsMultiplicative       = obj.Right.isMultiplicative;
        rightDependsOnName          = obj.Right.dependsOnName;
        operatorIsMultiplicative	= ~ismember(opText,{'+','-'});
        nameInExponent              = strcmp(opText,'^') & rightDependsOnName;
        
        tf = (leftIsMultiplicative && operatorIsMultiplicative && rightIsMultiplicative) || ...
             (~leftDependsOnName && ~rightDependsOnName);
        
        % If a name is in the exponent, the expression is not solely multiplicative with
        % respect to the names.
        tf = ~nameInExponent && tf;
        
    elseif ~isempty(obj.Operator)
        % Unary operator

        tf = obj.Left.isMultiplicative;
    else
        % Single value

        tf = true;
    end
end

