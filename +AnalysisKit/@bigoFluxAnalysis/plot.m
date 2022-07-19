function varargout = plot(obj,varargin)
% PLOT

    import DebuggerKit.Debugger.printDebugMessage
    import GraphKit.GraphTools.tightFig

    % Parse inputs
    [...
        obj,...
        variable,...
        plotType,...
        groupingParameter,...
        showConfidenceInterval,...
        figureProperties,...
        axesProperties] = parseInputs(obj,varargin{:});

    % Call the plot method of the superclass
    superInputs = {};
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


    % Validate variable(s)
    if isempty(variable)
        error('TODO')
    else
        if isnumeric(variable)
            variable = DataKit.Metadata.variable.fromProperty('Id',variable);
        elseif iscellstr(variable) || ischar(variable)
            variable = DataKit.Metadata.variable.fromProperty('Variable',variable);
        else
            error('Invalid type')
        end
    end
    variableIsNotInAnalysis = ~ismember(variable,cat(1,obj.FitVariables));
    if all(variableIsNotInAnalysis)
        error('Dingi:AnalysisKit:bigoFluxAnalysis:plot:unavailableVariables',...
            'None of the requested variables are part of the flux analysis.')
    end

    % Do the plotting
    switch plotType
        case 'fits'
            if ~isequal(groupingParameter,'none')
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:plot',...
                    'Verbose','For PlotType ''fits'', the grouping parameter is ignored. It was set to ''%s''.',groupingParameter)
            end
            [hsp,spi] = plotFits(obj,variable,showConfidenceInterval,axesProperties);
        case 'flux'
            [hsp,spi] = plotFlux(obj,variable,groupingParameter,axesProperties);
        case 'fluxViolin'
            plotFluxViolin(obj,variable,axesProperties)
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
    validPlotTypes  = {'fits','flux','fluxViolin'};
    validGroupingParameters = {'Cruise','Gear','AreaId'};

    % Define default values
    defaultVariable = [];
    defaultPlotType = 'flux';
    defaultGroupingParameter = 'Gear';
    defaultShowConfidenceInterval = true;
    defaultFigureProperties = {};
    defaultAxesProperties = {};

    % Define validationFunctions
    validateObj = @(x) isa(x,'AnalysisKit.bigoFluxAnalysis');
    validatePlotType = @(x) ~isempty(validatestring(x,validPlotTypes));
    validateVariable = @(x) true;
    validateShowConfidenceInterval = @(x) validateattributes(x,{'logical'},{'scalar','nonempty'});

    % Create input parser
    p = inputParser;
    addRequired(p,'obj',validateObj)
    addOptional(p,'variable',defaultVariable,validateVariable)
    addOptional(p,'plotType',defaultPlotType,validatePlotType)
    addParameter(p,'GroupingParameter',defaultGroupingParameter)
    addParameter(p,'ShowConfidenceInterval',defaultShowConfidenceInterval,validateShowConfidenceInterval)
    addParameter(p,'FigureProperties',defaultFigureProperties)
    addParameter(p,'AxesProperties',defaultAxesProperties)

    parse(p,obj,varargin{:})

    obj                     = p.Results.obj;
    variable                = p.Results.variable;
    plotType                = validatestring(p.Results.plotType,validPlotTypes);
    groupingParameter       = validatestring(p.Results.GroupingParameter,validGroupingParameters);
    showConfidenceInterval	= p.Results.ShowConfidenceInterval;
    figureProperties        = p.Results.FigureProperties;
    axesProperties          = p.Results.AxesProperties;
    varargout   = {...
        obj,...
        variable,...
        plotType,...
        groupingParameter,...
        showConfidenceInterval,...
        figureProperties,...
        axesProperties};

    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Dingi:AnalysisKit:analysis:plot:parseInputs:invalidNumberOfOutputs',...
          'Parsed variable number mismatches the output.')
	end
end
