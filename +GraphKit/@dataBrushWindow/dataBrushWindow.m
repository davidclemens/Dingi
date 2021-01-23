classdef dataBrushWindow < handle
% DATABRUSHWINDOW

    properties
        Figure
        Brush
        EnableBrushing = 'on'
    end
    properties (Dependent)
        Axes
        nAxes
        Charts
    end
    methods
        function obj = dataBrushWindow(hfig,varargin)

            import internal.stats.parseArgs

            % parse Name-Value pairs
            optionName          = {'Color'}; % valid options (Name)
            optionDefaultValue  = {[1 0 0]}; % default value (Value)
            [Color]     	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            obj.Figure  = hfig;
            obj.Brush   = brush(obj.Figure);
            obj.Brush.Enable = obj.EnableBrushing;
            obj.Brush.Color = Color;
        end
    end

    methods
        tbl = getBrushData(obj)

        % get methods
        function Axes = get.Axes(obj)
            Axes    = findobj(obj.Figure.Children,'Type','Axes');
        end
        function nAxes = get.nAxes(obj)
            nAxes    = numel(obj.Axes);
        end
        function Charts = get.Charts(obj)
            Charts = getBrushData(obj);
        end
        % set methods
        function obj = set.EnableBrushing(obj,value)
            switch value
                case 'on'
                    obj.Brush.Enable = 'on';
                case 'off'
                    obj.Brush.Enable = 'off';
                otherwise
                    error('Dingi:GraphKit:dataBrushWindow:dataBrushWindow:invalidState',...
                      '''%s'' is an invalid state for ''Enable Brushing''.',value)
            end
        end
    end
end
