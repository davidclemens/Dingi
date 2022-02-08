function varargout = plot(obj,varargin)
% PLOT

    % Parse inputs
    [...
        obj,...
        variable,...
        plotType,...
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
    axesProperties  = [axesProperties,'Parent',{hfig}];
    
    
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
            plotFits(obj,variable,axesProperties)
        case 'flux'
            plotFlux(obj,variable,axesProperties)
    end
    
%     TightFig(hfig,hsp,spi,PaperPos,MarginOuter,MarginInner);
    set(hfig,...
        'Visible',      'on');
end

function varargout = parseInputs(obj,varargin)

    % Define valid values
    validPlotTypes  = {'fits','flux'};
    
    % Define default values
    defaultVariable = [];
    defaultPlotType = 'fits';
    defaultFigureProperties = {};
    defaultAxesProperties = {};
    
    % Define validationFunctions
    validateObj = @(x) isa(x,'AnalysisKit.bigoFluxAnalysis');
    validatePlotType = @(x) ~isempty(validatestring(x,validPlotTypes));
    validateVariable = @(x) true;

    % Create input parser
    p = inputParser;
    addRequired(p,'obj',validateObj)
    addOptional(p,'variable',defaultVariable,validateVariable)
    addOptional(p,'plotType',defaultPlotType,validatePlotType)
    addParameter(p,'FigureProperties',defaultFigureProperties)
    addParameter(p,'AxesProperties',defaultAxesProperties)

    parse(p,obj,varargin{:})
    
    obj                 = p.Results.obj;
    variable            = p.Results.variable;
    plotType            = validatestring(p.Results.plotType,validPlotTypes);
    figureProperties   	= p.Results.FigureProperties;
    axesProperties   	= p.Results.AxesProperties;
    varargout   = {...
        obj,...
        variable,...
        plotType,...
        figureProperties,...
        axesProperties};
              
    % sanity check
	if numel(fieldnames(p.Results)) ~= numel(varargout)
        error('Dingi:AnalysisKit:analysis:plot:parseInputs:invalidNumberOfOutputs',...
          'Parsed variable number mismatches the output.')
	end
end