function varargout = plot(obj,parameter,varargin)
% PLOT plots sensor data from gearDeployment object(s)
% Plot the timeseries of selected/all parameters of a gearDeployment
% object.
%
% Syntax
%   PLOT(obj)
%
%   PLOT(obj,parameter)
%
%   PLOT(__,Name,Value)
%
%   [hfig] = PLOT(__)
%
%   [hfig,hsp] = PLOT(__)
%
% Description
%   PLOT(obj) plots the timeseries of all available parameters of all the
%       gearDeployment instances obj.
%
%   PLOT(obj,parameter) plots the timeseries of all provided parameters
%       parameter of all the gearDeployment instances obj.
%
%   PLOT(__,Name,Value) specifies additional properties using one or more
%       Name,Value pair arguments.
%
%   [hfig] = PLOT(__) additionally returns the figure handle.
%
%   [hfig,hsp] = PLOT(__) additionally returns the figure handle and the
%       subplot handle(s).
%
%
% Example(s) 
%
%
% Input Arguments
%   obj - gearDeployment instance
%       gearDeployment
%           An instance of the gearDeployment (super)class
%   parameter - list of parameters to plot
%       cellstr
%           List of parameters to plot.
%
%
% Output Arguments
%   hfig - figure handle
%       figure handle
%           Handle to the figure.
%   hsp - subplot handle(s)
%       axes handle
%           Array of axes handles to all subplots
%
%
% Name-Value Pair Arguments
%   FontSize - font size
%       10 (default) | numeric
%           Font size for the figure.
%   TitleFontSizeMultiplier - title font size multiplier
%       1 (default) | numeric
%           The font size for the titles are multiplied by this factor.
%   LabelFontSizeMultiplier - label font size multiplier
%       1 (default) | numeric
%           The font size for the labels are multiplied by this factor.
%
% 
% See also
%
% Copyright 2020 David Clemens (dclemens@geomar.de)
        
    import GraphKit.getMaxFigureSize
    import GraphKit.getDataLimits
    
    nvarargin   = numel(varargin);
    
    
    
    % parse Name-Value pairs
    optionName          = {'FontSize','TitleFontSizeMultiplier','LabelFontSizeMultiplier'}; % valid options (Name)
    optionDefaultValue  = {10,1,1}; % default value (Value)
    [FontSize,...
     TitleFontSizeMultiplier,...
     LabelFontSizeMultiplier,...
    ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
     
    % parse parameter input
    plotParametersAvailable = cat(1,obj.parameters);
    plotParametersAvailable = cellstr(unique(plotParametersAvailable.Parameter));
    if nargin - nvarargin == 1
        plotParameterY      = plotParametersAvailable;
    elseif nargin - nvarargin == 2
        if ischar(parameter)
            parameter	= cellstr(parameter);
        elseif ~iscellstr(parameter)
            error('GearKit:gearDeployment:plot:invalidParameterType',...
                  'The requested parameter has to be specified as a char or cellstr.')
        end
        plotParameterY      = parameter;
        im                  = ismember(plotParameterY,plotParametersAvailable);
        if ~all(im)
            error('GearKit:GearDeployment:plot:invalidParameter',...
                  'One or more specified parameters are invalid:\n\t%s\nValid parameters are:\n\t%s\n',strjoin(plotParameterY(~im),', '),strjoin(plotParametersAvailable,', '))
        end
    end
 	nParameter      	= numel(plotParameterY);
    
    % initialize figure
    hfig        = figure(99);
    set(hfig,...
       	'Visible',      'off');
    clf
    
    
    cmap                        = cbrewer('qual','Set1',7);
    fOutFigName                 = 'gear deployments';
    Menubar                     = 'figure';
    Toolbar                     = 'auto';
    maxFigureSize               = getMaxFigureSize('Menubar',Menubar);
    hsp                         = gobjects();
    hlgnd                       = gobjects();
    hp                          = gobjects();
    spnx                        = numel(obj);
    spny                        = nParameter;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
  	PaperWidth                  = maxFigureSize(1);
    PaperHeight                 = maxFigureSize(2);
    PaperPos                    = [PaperWidth PaperHeight];
    MarginOuter                 = 0.2;
    MarginInner                 = 0;  % cm

    set(hfig,...
        'Name',                 fOutFigName,...
        'Menubar',              Menubar,...
        'Toolbar',              Toolbar,...
        'PaperSize',            PaperPos,...
        'PaperOrientation',     'Portrait')
    
    parameterNotInDeployment    = false(spny,spnx);
    yLabelString                = repmat({''},spny,spnx);
    titleString                 = repmat({''},spny,spnx);
    for col = 1:spnx
        gear	= col;
        for row = 1:spny
            par     = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',                 'add',...
                                    'Layer',                    'top',...
                                    'Box',                      'off',...
                                    'FontSize',                 FontSize,...
                                    'TitleFontSizeMultiplier',  TitleFontSizeMultiplier,...
                                    'LabelFontSizeMultiplier',  LabelFontSizeMultiplier,...
                                    'TitleFontWeight',          'normal',...
                                    'TickDir',                  'out',...
                                    'ColorOrder',               cmap);
                try
                    [time,data,info]    = obj(gear).getData(plotParameterY{par},...
                                            'DeploymentDataOnly',       true,...
                                            'RelativeTime',             'h');
                catch ME
                    switch ME.identifier
                        case 'GearKit:gearDeployment:gd:invalidParameter'
                            parameterNotInDeployment(row,col) = true;
                        otherwise
                            rethrow(ME)
                    end
                end
                
                iihp    = 1;
                if isempty(time)
                    hp(1,spi(row,col)) = plot(NaT,NaN);
                elseif parameterNotInDeployment(row,col)
                    hp(1,spi(row,col)) = plot(NaT,NaN);
                else
                    for sens = 1:numel(time)
                        XData  	= time{sens};
                        YData	= movmean(data{sens},10/60,...
                                          'SamplePoints',     XData);
                        hptmp   = plot(XData,YData);
                        nhp     = numel(hptmp);
                        hp(iihp:iihp + nhp - 1,spi(row,col))	= hptmp;
                        iihp    = iihp + nhp;
                    end
                    hlgnd(spi(row,col))	= legend({info.name},...
                                                 'Location',        'best',...
                                                 'Interpreter',     'none');
                    yLabelString{row,col}	= [plotParameterY{par},' (',info(1).unit{:},')'];
                    titleString{row,col} 	= strjoin([cellstr(obj(gear).cruise),cellstr(obj(gear).gear)],' ');
                end
                
        end
    end
    
    % only keep the first occurance of the labels that is non-empty
    yLabelString    = yLabelString(cumsum(~cellfun(@isempty,yLabelString),2) == 1);
    titleString     = titleString(cumsum(~cellfun(@isempty,titleString),1) == 1);
    
    % set appearance and labels
    for col = 1:spnx
        gear	= col;
        for row = 1:spny
            par     = row;      
            if col == 1
                ylabel(hsp(spi(row,col)),yLabelString{row});
                set(hsp(spi(row,col)).YAxis,...
                    'Color',            'k');
            else
                set(hsp(spi(row,col)),...
                    'YColor',           'none');
                set(hsp(spi(row,col)).YAxis,...
                    'Visible',          'off');
            end
            if row == spny
                set(hsp(spi(row,col)).XAxis,...
                    'Color',            'k');
            else
                set(hsp(spi(row,col)),...
                    'XColor',           'none');
                set(hsp(spi(row,col)).XAxis,...
                    'Visible',          'off');
            end
            if row == 1
                title(hsp(spi(row,col)),titleString{col})
            end
            if parameterNotInDeployment(row,col)
                text(hsp(spi(row,col)),0.5,0.5,'no data',...
                    'Units',                'normalized',...
                    'HorizontalAlignment',  'center',...
                    'FontSize',             FontSize*LabelFontSizeMultiplier)
            end
        end
    end
    
    
    iilnk   = 1;
    for row = 1:spny
        YLim            = getDataLimits(hp(:,spi(row,:)),'Y');
        set(hsp(spi(row,:)),...
            {'YLim'},   repmat(YLim,size(hsp(spi(row,:))))')
        
        hlnk(iilnk)     = linkprop(hsp(spi(row,:)),'YLim');
        iilnk           = iilnk + 1;
    end
    for col = 1:spnx
        XLim            = getDataLimits(hp(:,spi(:,col)),'X');
        set(hsp(spi(:,col)),...
            {'XLim'},   repmat(XLim,size(hsp(spi(:,col))))')
        
        hlnk(iilnk)     = linkprop(hsp(spi(:,col)),'XLim');
        iilnk           = iilnk + 1;
    end
    hfig.UserData   = hlnk;
    varargout{1}    = hfig;
    varargout{2}    = hsp;
    
    TightFig(hfig,hsp(1:spnx*spny),spi,PaperPos,MarginOuter,MarginInner);
    
    hfig.Visible    = 'on';
end