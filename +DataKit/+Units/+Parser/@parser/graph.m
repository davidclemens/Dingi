function h = graph(obj)
% graph  Plot parser as graph
%   GRAPH plots a parser instance as an evaluation graph, showing the order of
%   operations
%
%   Syntax
%     h = GRAPH(obj)
%
%   Description
%     h = GRAPH(obj)  Plots evaluation graph of parser obj and returns handle h
%       to the graph
%
%   Example(s)
%
%
%   Input Arguments
%     obj - Parser
%       DataKit.Units.Parser.parser
%         Parser specified as a DataKit.Units.Parser.parser instance.
%
%
%   Output Arguments
%     h - Graph plot handle
%       handle
%         Handle to the GraphPlot, returned as a handle.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.UNITS.PARSER.PARSER, DATAKIT.UNITS.PARSER.EVALTREENODE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    [edgeTable,nodeTable] = obj.Tree.graphTables();

    G = digraph(edgeTable,nodeTable);
    h = G.plot(...
        'EdgeColor',    'k',...
        'EdgeAlpha',    1,...
        'LineWidth',    1,...
        'Marker',       'o',...
        'NodeColor',    'k',...
        'Layout',       'layered');
    nodeIds = 1:size(G.Nodes,1);
    lables  = G.Nodes.Label;
    h.labelnode(nodeIds,lables)
    h.highlight(~G.Nodes{:,'DependsOnName'},...
        'NodeColor',    [0 .75 0])
    h.highlight(G.Nodes{:,'DependsOnName'},...
        'MarkerSize',   8)
    maskDependsOnNameEdges = all(~G.Nodes.DependsOnName(G.Edges.EndNodes),2);
    h.highlight(G.Edges.EndNodes(maskDependsOnNameEdges,1),G.Edges.EndNodes(maskDependsOnNameEdges,2),...
        'EdgeColor',    [0 .75 0],...
        'LineWidth',    0.5)
    hax = gca;

    FontSize = 16;
    set(hax,...
        'FontSize',                 FontSize,...
        'LabelFontSizeMultiplier',  16/FontSize,...
        'TitleFontSizeMultiplier',  18/FontSize)
end

