function varargout = plot(obj,varargin)

    import GraphKit.getMaxFigureSize
    import GraphKit.Colormaps.cm
    
    % Parse inputs
    [...
        plotType,...
        figureProperties,...
        axesProperties ...
    ] = parseInputs(varargin{:});

    % Define default values
    maxFigureSize	= getMaxFigureSize;
    paperHeight   	= maxFigureSize(2);
    paperWidth  	= paperHeight/2;
    paperPos       	= [paperWidth paperHeight];
    cMap            = cm('Set1',7);
    
    switch class(obj)
        case 'AnalysisKit.bigoFluxAnalysis'
            switch plotType
                case 'fits'
                    defaultFigureNumber = 40;
                case 'flux'
                    defaultFigureNumber = 41;
                case 'fluxViolin'
                    defaultFigureNumber = 42;
            end
        otherwise
            defaultFigureNumber = 20;
    end
    
    defaultFigureProperties = {...
        'Number',               defaultFigureNumber,...
        'Visible',              'on',...
        'Name',                 'Analysis',...
        'Menubar',              'figure',...
        'Toolbar',              'auto',...
        'PaperUnits',           'centimeters',...
        'PaperSize',            paperPos,...
        'PaperOrientation',     'Portrait',...
        'Units',                'normalized',...
        'Position',             [0.5 0 0.5 1]};
    defaultAxesProperties = {...
        'NextPlot',                 'add',...
        'XColor',                   'k',...
        'YColor',                   'k',...
        'FontSize',                 12,...
        'TitleFontSizeMultiplier',  1,...
        'LabelFontSizeMultiplier',  1,...
        'TitleFontWeight',          'normal',...
        'Box',                      'on',...
        'ColorOrder',               cMap};
    
    % Merge specified values with default values
    figureProperties    = mergeWithDefaults(figureProperties,defaultFigureProperties);
    axesProperties      = mergeWithDefaults(axesProperties,defaultAxesProperties);
    
    % Extract figure number
    numberPropertyIndex = find(ismember(figureProperties(1:2:end),{'Number'}))*2;
    figureNumber        = figureProperties{numberPropertyIndex};
    figureProperties(numberPropertyIndex - 1:numberPropertyIndex) = [];
    
    % Create figure and set properties
    hfig    = figure(figureNumber);
    clf
    set(hfig,figureProperties{:},...
        'Visible',  'off')
    
    varargout = {...
        hfig,...
        axesProperties};
end

function varargout = parseInputs(varargin)
    
    % Define default values
    defaultFigureProperties = {};
    defaultAxesProperties = {};

    % Create input parser
    p = inputParser;
    addRequired(p,'plotType')
    addParameter(p,'FigureProperties',defaultFigureProperties)
    addParameter(p,'AxesProperties',defaultAxesProperties)
    
    parse(p,varargin{:})

    plotType            = p.Results.plotType;
    figureProperties   	= p.Results.FigureProperties;
    axesProperties   	= p.Results.AxesProperties;
    
    varargout   = {...
        plotType,...
        figureProperties,...
        axesProperties};
              
    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Dingi:AnalysisKit:analysis:plot:parseInputs:invalidNumberOfOutputs',...
          'Parsed variable number mismatches the output.')
	end
end

function merged = mergeWithDefaults(in,default)

    tmp     = reshape(cat(2,in,default),2,[])';
    [u,ind] = unique(tmp(:,1),'stable');
    merged	= cat(2,u,tmp(ind,2));
    merged  = reshape(merged',1,[]);
end
