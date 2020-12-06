function varargout = plot(obj,variables,varargin)
% plot  plots sensor data from gearDeployment object(s)
%   PLOT the timeseries of selected/all parameters of a gearDeployment
%   object. Overloads the builtin plot function.
%
%   Syntax
%     PLOT(obj)
%     PLOT(obj,parameter)
%     PLOT(__,Name,Value)
%     [hfig] = PLOT(__)
%     [hfig,hsp] = PLOT(__)
%
%   Description
%     PLOT(obj) plots the timeseries of all available parameters of all the
%       gearDeployment instances obj.
%
%     PLOT(obj,parameter) plots the timeseries of all provided parameters
%       parameter of all the gearDeployment instances obj.
%
%     PLOT(__,Name,Value) specifies additional properties using one or more
%       Name,Value pair arguments.
%
%     [hfig] = PLOT(__) additionally returns the figure handle.
%
%     [hfig,hsp] = PLOT(__) additionally returns the figure handle and the
%       subplot handle(s).
%
%
%   Example(s) 
%
%
%   Input Arguments
%     obj - gearDeployment instance
%       gearDeployment
%         An instance of the gearDeployment (super)class
%
%     parameter - list of parameters to plot
%       cellstr
%         List of parameters to plot.
%
%
%   Output Arguments
%     hfig - figure handle
%       figure handle
%         Handle to the figure.
%
%     hsp - subplot handle(s)
%       axes handle
%         Array of axes handles to all subplots
%
%
%   Name-Value Pair Arguments
%     FontSize - font size
%       10 (default) | numeric
%         Font size for the figure.
%
%     TitleFontSizeMultiplier - title font size multiplier
%       1 (default) | numeric
%         The font size for the titles are multiplied by this factor.
%
%     LabelFontSizeMultiplier - label font size multiplier
%       1 (default) | numeric
%         The font size for the labels are multiplied by this factor.
%
%   
%   See also
%
%   Copyright 2020 David Clemens (dclemens@geomar.de)
%
        
    import GraphKit.getMaxFigureSize
    import GraphKit.getDataLimits   
    
    %   Figure settings
	Menubar                     = 'figure';
    maxFigureSize               = getMaxFigureSize('Menubar',Menubar);
    PaperWidth                  = maxFigureSize(1);
    PaperHeight                 = maxFigureSize(2);
    PaperPos                    = [PaperWidth PaperHeight];
    
    %   Axis settings
    cmap                        = cbrewer('qual','Set1',7);
    
    %   parse Name-Value pairs
    optionName          = {'FigureNameValue','AxisNameValue','DataDomain','LegendVisible','MarginOuter','MarginInner','RelativeTime'}; %   valid options (Name)
    optionDefaultValue  = {{'Name',                 'gear deployments',...
                            'Menubar',              Menubar,...
                            'Toolbar',              'auto',...
                            'PaperSize',            PaperPos,...
                            'PaperOrientation',     'Portrait'},...
                           {'NextPlot',                 'add',...
                            'Layer',                    'top',...
                            'Box',                      'off',...
                            'FontSize',                 12,...
                            'TitleFontSizeMultiplier',  1,...
                            'LabelFontSizeMultiplier',  1,...
                            'TitleFontWeight',          'normal',...
                            'TickDir',                  'out',...
                            'ColorOrder',               cmap},...
                            {},...
                            'show',...
                            0.5,...
                            0.2,...
                            'h'}; %   default value (Value)
    [FigureNameValue,...
     AxesNameValue,...
     DataDomain,...
     LegendVisible,...
     MarginOuter,...
     MarginInner,...
     RelativeTime,...
    ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); %   parse function arguments   
    
    %   parse parameter input
    plotVariablesAvailableInfo	= cat(1,obj.variables);
    if exist('variables','var') ~= 1
        [variableIsValid,variableInfo]    = DataKit.Metadata.variable.validateId(plotVariablesAvailableInfo{:,'Id'});
%         error('TODO: implement a selection of all available variables. All is too many.')
    else
        if ischar(variables) || iscellstr(variables)
            if ischar(variables)
                variables   = cellstr(variables);
            end
            variables	= variables(:);
            [variableIsValid,variableInfo]    = DataKit.Metadata.variable.validateStr(variables);
        elseif isnumeric(variables)
            variables	= variables(:);
            [variableIsValid,variableInfo]    = DataKit.Metadata.variable.validateId(variables);
        else
            error('GearKit:gearDeployment:plot:invalidVariableType',...
                  'The requested parameter has to be specified as a char, cellstr or numeric vector.')
        end
    end    
    variables   = variableInfo{variableIsValid,'Variable'};
    im          = ismember(variable2str(variables),plotVariablesAvailableInfo{:,'Name'});
    if ~all(im)
        error('GearKit:GearDeployment:plot:invalidVariables',...
              'One or more specified variables are invalid:\n\t%s\nValid variables are:\n\t%s\n',strjoin(variable2str(variables(~im)),', '),strjoin(cellstr(plotVariablesAvailableInfo{:,'Name'}),', '))
    end
 	nVariables          = numel(variables);
    
    %   initialize figure
    hfig        = figure(99);
    set(hfig,...
       	'Visible',      'on');
    clf
    set(hfig,FigureNameValue{:})
    
    
    
    hsp                         = gobjects();
    hlgnd                       = gobjects();
    hp                          = gobjects();
    spnx                        = numel(obj);
    spny                        = nVariables;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
        
    parameterNotInDeployment    = false(spny,spnx);
    yLabelString                = repmat({''},spny,spnx);
    titleString                 = repmat({''},spny,spnx);
    for col = 1:spnx
        gear	= col;
        for row = 1:spny
            v     = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),AxesNameValue{:});
                try
                    data    = obj(gear).fetchData(variables(v),...
                                'TimeOfInterestDataOnly',   true,...
                                'RelativeTime',             'h',...
                                'GroupBy',                  'MeasuringDevice');
                catch ME
                    switch ME.identifier
                        case 'GearKit:gearDeployment:gd:invalidParameter'
                            parameterNotInDeployment(row,col) = true;
                        otherwise
                            rethrow(ME)
                    end
                end

                
                if ~isempty(DataDomain)
                    maskDataDomain  = cat(1,data.DependantInfo.MeasuringDevice.WorldDomain) == DataDomain;
                    data.IndependantVariables               = data.IndependantVariables(maskDataDomain,:);
                    data.DependantVariables                 = data.DependantVariables(maskDataDomain,:);
                    data.IndependantInfo.MeasuringDevice    = data.IndependantInfo.MeasuringDevice(maskDataDomain);
                    data.DependantInfo.MeasuringDevice      = data.DependantInfo.MeasuringDevice(maskDataDomain);
                end
                
                iihp    = 1;
                if isempty(data.IndepData)
                    hp(1,spi(row,col)) = plot(NaT,NaN);
%               elseif parameterNotInDeployment(row,col)
%                   hp(1,spi(row,col)) = plot(NaT,NaN);
                else
                    legendStr   = cell.empty;
                    for gr = 1:size(data.IndepData,1)
                        XData  	= data.IndepData{gr}{:};
                        YData	= data.DepData{gr};
                        hptmp   = plot(XData,YData,...
                                    'LineWidth',    1.5);
                        legendStr   = cat(1,legendStr,{[char(data.DepInfo(gr).MeasuringDevice.Type),' ',...
                                                        char(data.DepInfo(gr).MeasuringDevice.WorldDomain)]});
                                
                        nhp     = numel(hptmp);
                        hp(iihp:iihp + nhp - 1,spi(row,col))	= hptmp;
                        iihp    = iihp + nhp;
                    end
                    hlgnd(spi(row,col))	= legend(legendStr,...
                                                 'Location',        'best',...
                                                 'Interpreter',     'none');
                    legend(LegendVisible)
                    yLabelString{row,col}	= [char(variableInfo{v,'Abbreviation'}),'\color[rgb]{0.6 0.6 0.6} (',char(variableInfo{v,'Unit'}),')'];
                    titleString{row,col} 	= strjoin([cellstr(obj(gear).cruise),cellstr(obj(gear).gear)],' ');
                end
        end
    end
    
    %   only keep the first occurance of the labels that is non-empty
    yLabelString    = yLabelString(cumsum(~cellfun(@isempty,yLabelString),2) == 1);
    titleString     = titleString(cumsum(~cellfun(@isempty,titleString),1) == 1);
    
    %   set appearance and labels
    for col = 1:spnx
        gear	= col;
        for row = 1:spny
            v     = row;      
            if col == 1
                ylabel(hsp(spi(row,col)),yLabelString{row});
                set(hsp(spi(row,col)).YAxis,...
                    'Color',            'k');
            else
                set(hsp(spi(row,col)),...
                    'YColor',           'none');
                set(hsp(spi(row,col)),...
                    'YTickLabel',       '');
                set(hsp(spi(row,col)).YAxis,...
                    'Visible',          'off');
            end
            if row == spny
                set(hsp(spi(row,col)).XAxis,...
                    'Color',            'k');
            else
                set(hsp(spi(row,col)),...
                    'XColor',           'none');
                set(hsp(spi(row,col)),...
                    'XTickLabel',     	'');
                set(hsp(spi(row,col)).XAxis,...
                    'Visible',          'off');
            end
            if row == 1
%               title(hsp(spi(row,col)),titleString{col})
            end
            if parameterNotInDeployment(row,col)
                text(hsp(spi(row,col)),0.5,0.5,'no data',...
                    'Units',                'normalized',...
                    'HorizontalAlignment',  'center',...
                    'FontSize',             FontSize*LabelFontSizeMultiplier)
            end
            if row == spny
                xlabel(hsp(spi(row,col)),['time\color[rgb]{0.6 0.6 0.6} (',RelativeTime,')'])
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
    
    TightFig(hfig,hsp(1:spnx*spny),spi,FigureNameValue{find(strcmp('PaperSize',FigureNameValue)) + 1},MarginOuter,MarginInner);
    
    hfig.Visible    = 'on';
end