function maxFigureSize = getMaxFigureSize(varargin)
    optionName          = {'Units','Menubar','Toolbar'}; % valid options (Name)
    optionDefaultValue  = {'centimeters','figure','auto'}; % default value (Value)
    [Units,Menubar,Toolbar]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    h   = figure(...
            'Units',        'normalized',...
            'Position',     [0 0 1 1],...
            'Visible',      'off',...
            'Menubar',      Menubar,...
            'Toolbar',      Toolbar);
    drawnow()
    h.Units         = Units;
    maxFigureSize   = h.Position(3:4);
    close(h);
end