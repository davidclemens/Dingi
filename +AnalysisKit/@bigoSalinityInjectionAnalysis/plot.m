function varargout = plot(obj,varargin)

    import DebuggerKit.Debugger.printDebugMessage
    import GraphKit.GraphTools.tightFig

    nargoutchk(0,1)
    
    % Parse inputs
    [...
        obj,...
        plotType,...
        figureProperties,...
        axesProperties] = parseInputs(obj,varargin{:});

    % Call the plot method of the superclass
    superInputs = {plotType};
    if ~isempty(figureProperties)
        superInputs     = [superInputs,{'FigureProperties',figureProperties}];
    end
    if ~isempty(axesProperties)
        superInputs     = [superInputs,{'AxesProperties',axesProperties}];
    end
    [...
        hfig,...
        axesProperties] = plot@AnalysisKit.analysis(obj,superInputs{:});

    % Add figure handle to axes properties
    axesProperties  = [axesProperties,...
        'Parent',   {hfig},...
        'NextPlot', 'add'];

    % Do the plotting
    switch plotType
        case 'overview'
            [hsp,spi] = plotOverview(obj,axesProperties);
    end

    marginOuter     = 0.2;
    marginInner     = 0.2;
    figUnits        = hfig.Units;
    set(hfig,'Units','centimeters')
    tightFig(hfig,hsp,spi,hfig.PaperPosition(3:4),marginOuter,marginInner);
    set(hfig,...
        'Visible',      'on',...
        'Units',        figUnits);
    
    if nargout == 1
        varargout{1} = hfig;
    end
end

function varargout = parseInputs(obj,varargin)

    % Define valid values
    validPlotTypes  = {'overview'};

    % Define default values
    defaultPlotType = 'overview';
    defaultFigureProperties = {};
    defaultAxesProperties = {};

    % Define validationFunctions
    validateObj = @(x) isa(x,'AnalysisKit.bigoSalinityInjectionAnalysis');
    validatePlotType = @(x) ~isempty(validatestring(x,validPlotTypes));

    % Create input parser
    p = inputParser;
    addRequired(p,'obj',validateObj)
    addOptional(p,'plotType',defaultPlotType,validatePlotType)
    addParameter(p,'FigureProperties',defaultFigureProperties)
    addParameter(p,'AxesProperties',defaultAxesProperties)

    parse(p,obj,varargin{:})

    obj                     = p.Results.obj;
    plotType                = validatestring(p.Results.plotType,validPlotTypes);
    figureProperties        = p.Results.FigureProperties;
    axesProperties          = p.Results.AxesProperties;
    varargout   = {...
        obj,...
        plotType,...
        figureProperties,...
        axesProperties};

    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Dingi:AnalysisKit:analysis:plot:parseInputs:invalidNumberOfOutputs',...
          'Parsed variable number mismatches the output.')
	end
end
