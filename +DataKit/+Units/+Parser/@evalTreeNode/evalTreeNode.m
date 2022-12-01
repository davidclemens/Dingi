classdef evalTreeNode
% EVALTREENODE  Single node within an evaluation tree
% A single node within an evaluation tree. Each node can have a left and right
% side as well as an operator that combines the former two. The operator or the
% right side can be left empty. This results in the following cases:
%   1. Left, Operator, Right -> binary operation (e.g. '5 + 2')
%   2. Left, Operator        -> unary operation (e.g. '-5')
%   3. Left, Right           -> implicit multiplication (e.g. '3 kg')
%   4. Left                  -> single value (e.g. '4')
%
% EVALTREENODE Properties:
%   Left - Left side of the node
%   Operator - Node operator
%   Right - Right side of the node
%
% EVALTREENODE Methods:
%   char - Evaluation tree node to character array
%   dependsOnName - Determine if node depends on any NAME token
%   graphTables - Evaluation tree node to edgeTable & nodeTable
%
%
% Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    properties
        Left % Left side of the node
        Operator % Node operator
        Right % Right side of the node
    end
    
    % Constructor
    methods
        function obj = evalTreeNode(varargin)
            
            import internal.stats.parseArgs

            % Parse Name-Value pairs
            optionName          = {'Left','Operator','Right'}; % valid options (Name)
            optionDefaultValue  = {char.empty,char.empty,char.empty}; % default value (Value)
            [left,...
             operator,...
             right...
                ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            obj.Left        = left;
            obj.Operator    = operator;
            obj.Right       = right;
        end
    end
    
    methods
        C = char(obj,varargin)
        [edgeTable,nodeTable] = graphTables(obj,varargin)
        tf = dependsOnName(obj)
    end
end

