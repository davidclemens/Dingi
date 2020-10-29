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
        function obj = dataBrushWindow(hfig)
            
            obj.Figure  = hfig;
            obj.Brush   = brush(obj.Figure);
            obj.Brush.Enable = obj.EnableBrushing;
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
                    error('Invalid')
            end
        end
    end
end