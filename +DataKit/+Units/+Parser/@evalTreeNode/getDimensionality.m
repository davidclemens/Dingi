function [names,dimensionality,value] = getDimensionality(obj)
% getDimensionality  Dimensionality of names in multiplicative expression
%   GETDIMENSIONALITY returns the dimensionality of all the names occurring in
%   an expression. With multiple nested nodes, this becomes a recursive
%   algorithm.
%
%   Syntax
%     [names,dimensionality] = GETDIMENSIONALITY(obj)
%     [names,dimensionality,value] = GETDIMENSIONALITY(obj)
%
%   Description
%     [names,dimensionality] = GETDIMENSIONALITY(obj)  returns the names and
%       their dimensionality of all tokens of type 'NAME' with a non-zero
%       dimensionality.
%     [names,dimensionality,value] = GETDIMENSIONALITY(obj)  Additionally
%       returns value. Only used internally in recursive context.
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
%     names - List of names
%       cellstr
%         List of all tokens of type 'NAME', that have a non-zero
%         dimensionality, returned as a cellstr.
%
%     dimensionality - Dimensionality of names
%       integer column vector
%         Dimensionality of the names names, returned as an integer column
%         vector.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.UNITS.PARSER.EVALTREENODE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    if nargin == 1
        names = {};
        dimensionality = [];
        value = [];
    end
    
    if ~obj.isMultiplicative
        error('Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeExpression',...
            'Non-multiplicative expressions are not supported.')
    end
    
    if ~isempty(obj.Right)
        % Binary or implicit operator

        % Handle implicit operator
        if ~isempty(obj.Operator)
            opText = obj.Operator.ExactType;
        else
            opText = '';
        end
        
        [leftNames,leftDimensionality]              = obj.Left.getDimensionality;
        [rightNames,rightDimensionality,rightValue] = obj.Right.getDimensionality;

        switch opText
            case 'POWER'
                if ~isempty(leftNames) && ~isempty(rightValue)
                    leftDimensionality  = leftDimensionality * rightValue;
                end
            case 'DIVIDE'
                rightDimensionality = -rightDimensionality;
        end
        
        [names,dimensionality] = appendVar(leftNames,leftDimensionality,names,dimensionality);
        [names,dimensionality] = appendVar(rightNames,rightDimensionality,names,dimensionality);
    elseif ~isempty(obj.Operator)
        % Unary operator
        
        [leftNames,leftDimensionality,leftValue] = obj.Left.getDimensionality;
        
        switch obj.Operator.ExactType
            case 'MINUS'
                value = -leftValue;
            case 'PLUS'
                value = +leftValue;
        end
        names   	= leftNames;
        dimensionality  = leftDimensionality;
    else
        % Single value
        if obj.isMultiplicative
            if obj.dependsOnName
                % Append variable with degree 1
              	[names,dimensionality] = appendVar(obj.Left.Text,1,names,dimensionality);
            else
                % Return value
                value = str2double(obj.Left.Text);
            end
        else
            error('Non multiplicative')
        end
    end
    
    function [var,degree] = appendVar(newVar,newDegree,var,degree)
        
        if ischar(newVar)
            newVar = cellstr(newVar);
        end
        
        if isempty(newVar)
            return
        end
        
        [im,imInd] = ismember(newVar,var);
        
        if any(~im)
            % Add new variables that do not exist in list yet
            var     = cat(1,var,newVar(~im));
            degree	= cat(1,degree,newDegree(~im));
        end
        if any(im)
            % Update degree of variables that exist in list already
            degree(imInd(im)) = degree(imInd(im)) + newDegree(im);
        end
        
        % Remove cancelled variables
        degreeIsZero = degree == 0;
        if any(degreeIsZero)
            var(degreeIsZero)       = [];
            degree(degreeIsZero)    = [];
        end
    end
end

