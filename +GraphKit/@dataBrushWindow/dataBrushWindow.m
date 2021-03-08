classdef dataBrushWindow < handle
% DATABRUSHWINDOW

    properties
        Figure
        Brush
        BrushChangedFcn function_handle
        BrushDataChanged = false;
        BrushDataHash = {'';''};
    end
    properties (SetObservable)
        EnableBrushing logical = true
    end
    properties (Dependent,SetObservable)
        Axes
        nAxes
        Charts
    end
    methods
        function obj = dataBrushWindow(hfig,varargin)

            import internal.stats.parseArgs

            % parse Name-Value pairs
            optionName          = {'Color','BrushChangedFcn','EnableBrushing'}; % valid options (Name)
            optionDefaultValue  = {[1 0 0],function_handle.empty,true}; % default value (Value)
            [color,...
             brushChangedFcn,...
             enableBrushing]     	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            addlistener(obj,'EnableBrushing','PostSet',@GraphKit.dataBrushWindow.setBrushMode);
            
            obj.Figure  = hfig;
            obj.Brush   = brush(obj.Figure);
            obj.EnableBrushing = enableBrushing;
            obj.Brush.Color = color;
            obj.Brush.ActionPreCallback = @GraphKit.dataBrushWindow.brushPreFcn;
            obj.Brush.ActionPostCallback = @GraphKit.dataBrushWindow.brushPostFcn;
            obj.BrushChangedFcn = brushChangedFcn;
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
    end
    methods (Static)
        hash = createHash(cell)
        function brushPreFcn(src,evnt)
            df  = src.UserData.dataFlagger;
            br  = df.DataBrush;
            br.BrushDataHash{1} = br.createHash(br.Charts.brushData);
            br.BrushDataChanged = false;
        end
        function brushPostFcn(src,evnt)
            df  = src.UserData.dataFlagger;
            br  = df.DataBrush;
            br.BrushDataHash{2} = br.createHash(br.Charts.brushData);
            br.BrushDataChanged = ~strcmp(br.BrushDataHash{1},br.BrushDataHash{2});
            br.BrushChangedFcn(src,evnt);
        end
        function setBrushMode(~,evnt)
            br = evnt.AffectedObject;
            switch br.EnableBrushing
                case true
                    br.Brush.Enable = 'on';
                case false
                    br.Brush.Enable = 'off';
            end
        end
    end
end
