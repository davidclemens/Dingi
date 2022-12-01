function [edgeTable,nodeTable] = graphTables(obj,varargin)
% graphTables  Evaluation tree node to edgeTable & nodeTable
%   GRAPHTABLES converts an evaluation tree node into an edgeTable and
%   nodeTable. With multiple nested nodes, this becomes a recursive algorithm.
%
%   Syntax
%     [edgeTable,nodeTable] = GRAPHTABLES(obj)
%     [edgeTable,nodeTable] = GRAPHTABLES(__,Name,Value)
%
%   Description
%     [edgeTable,nodeTable] = GRAPHTABLES(obj)  Convert evalTreeNode obj into
%       edgeTable edgeTable and nodeTable nodeTable.
%     [edgeTable,nodeTable] = GRAPHTABLES(__,Name,Value)  Add additional options
%       specified by one or more Name,Value pair arguments.
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
%     edgeTable - Table of edge information
%       table
%         Table of edge information. The first variable in EdgeTable is a
%         two-column matrix called EndNodes that defines the graph edges.
%
%     nodeTable - Table of node information
%       table
%         Table of node information. The first variable in NodeTable is a
%         cellstr called Label and holds the label of the node.
%
%
%   Name-Value Pair Arguments
%     EdgeTable - Existing table of edge information
%       table
%         The current edgeTable specified as a table. This parameter is used in
%         the recursive context.
%
%     NodeTable - Existing table of node information
%       table
%         The current nodeTable specified as a table. This parameter is used in
%         the recursive context.
%
%     ParentNodeInd - Node index of the caller
%       [] (default) | positive integer scalar
%         The node index of the parent evaluation tree node, if used in the 
%         recursive context.
%
%
%   See also DATAKIT.UNITS.PARSER.EVALTREENODE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import internal.stats.parseArgs

    % Parse Name-Value pairs
    optionName          = {'EdgeTable','NodeTable','ParentNodeInd'}; % valid options (Name)
    optionDefaultValue  = {table(),table(),[]}; % default value (Value)
    [edgeTable,...
     nodeTable,...
     ParentNodeInd...
        ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    if ~isempty(obj.Right)
        % Binary or implicit operator
        
        if ~isempty(obj.Operator)
            % Binary operator
            operator = obj.Operator.Text;
        else
            % Implicit operator
            operator = '';
        end
        nodeId = size(nodeTable,1) + 1;
        nodeTable.Label(nodeId) = {operator};
        
        [edgeTable,nodeTable] = graphTables(obj.Left,...
            'EdgeTable',        edgeTable,...
            'NodeTable',        nodeTable,...
            'ParentNodeInd',	nodeId);
        
        [edgeTable,nodeTable] = graphTables(obj.Right,...
            'EdgeTable',        edgeTable,...
            'NodeTable',        nodeTable,...
            'ParentNodeInd',	nodeId);
        
        if ~isempty(ParentNodeInd)
            edgeTable   = cat(1,edgeTable,table([nodeId,ParentNodeInd],'VariableNames',{'EndNodes'}));
        end
    elseif ~isempty(obj.Operator)
        % Unary operator
        nodeId = size(nodeTable,1) + 1;
        nodeTable.Label(nodeId) = {obj.Operator.Text};
        
        [edgeTable,nodeTable] = graphTables(obj.Left,...
            'EdgeTable',        edgeTable,...
            'NodeTable',        nodeTable,...
            'ParentNodeInd',	nodeId);

        if ~isempty(ParentNodeInd)
            edgeTable   = cat(1,edgeTable,table([nodeId,ParentNodeInd],'VariableNames',{'EndNodes'}));
        end
    else
        % Single value
        nodeId = size(nodeTable,1) + 1;
        nodeTable.Label(nodeId) = {obj.Left.Text};
        edgeTable   = cat(1,edgeTable,table([nodeId,ParentNodeInd],'VariableNames',{'EndNodes'}));
        return
    end
end

