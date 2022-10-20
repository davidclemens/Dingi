function varargout = plot(obj,varargin)
% plot  Plot a bigoFluxAnalysis instance
%   PLOT creates plots for bigoFluxAnalysis instance(s) to show the fits or the
%   fluxes.
%
%   Syntax
%     PLOT(A)
%     PLOT(A,variables)
%     PLOT(A,variables,plotType)
%     PLOT(__,Name,Value)
%     hfig = PLOT(__)
%
%   Description
%     PLOT(A) plots the fluxes of 5 default variables (oxygen, ammonium,
%       nitrate, nitrite, phosphate) grouped by gear.
%     PLOT(A,variables) plots the fluxes of variables variables grouped by
%       gear.
%     PLOT(A,variables,plotType) additionally specifies the plot type.
%     PLOT(__,Name,Value) additionally specifies Name-Value pairs.
%     hfig = PLOT(__) returns the figure handle of the resulting figure
%
%   Example(s)
%     plot(A)
%     plot(A,{'Ox','Silicate'},'GroupingParameter','AreaId')
%     plot(A,{'Ammonium','Nitrate'},'fits')
%
%
%   Input Arguments
%     A - bigoFluxAnalyis instance
%       scalar or array of bigoFluxAnalysis instances
%         The bigoFluxAnalysis instances to include in the plots.
%
%     variables - variables
%       char | cellstr
%         A list of valid variables of which the fits/fluxes should be shown.
%
%     plotType - plot type
%       'flux' (default) | 'fits' | 'fluxViolin'
%         The plot type.
%           - fits:         Shows the raw incubation data together with the
%                           calculated fits. Use to evaluate the quality of
%                           fits.
%           - flux:         Shows the calculated fluxes resulting from the fits. 
%                           The fluxes are calculated by evaluating the fits 
%                           within the 'FitEvaluationInterval' and normalized to
%                           the time unit set in 'TimeUnit'.
%           - fluxViolin:   Same as 'flux', but showing the fluxes as violin
%                           plots.
%
%
%   Output Arguments
%     hfig - figure handle
%       figure handle
%         The handle of the resulting figure.
%
%
%   Name-Value Pair Arguments
%     GroupingParameter - The parameter to group fluxes by
%       'Gear' (default) | 'Cruise' | 'AreaId'
%         The parameter to group fluxes by, if plotType is set to flux or
%         fluxViolin.
%
%     ShowConfidenceInterval - Also show the confidence interval
%       true (default) | false
%         Determines if the confidence interval of the fits should also be
%         shown, if the plotType is set to fits.
%
%     FigureProperties - Figure properties
%       cell array
%         Name-Value pairs in form of a cell array that should be set as figure 
%         properties.
%
%     AxesProperties - Axes properties
%       cell array
%         Name-Value pairs in form of a cell array that should be set as axes 
%         properties.
%
%
%   See also 
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    import DebuggerKit.Debugger.printDebugMessage
    import GraphKit.GraphTools.tightFig

    nargoutchk(0,1)
    
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

    % Validate variable(s)
    if isempty(variable)
        % If no variables are provided, use these default variables
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:plot:showingDefaultVariables',...
            'Info','No variables were provided. Default variables are shown.')
        defaultVariables = {'Oxygen','Ammonium','Nitrate','Nitrite','Phosphate'};
        variable = DataKit.Metadata.variable.fromProperty('Variable',defaultVariables);
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
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:plot:ignoredGroupingParameter',...
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
    validateVariable = @(x) validateattributes(x,{'char','cell'},{'nonempty'});
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
