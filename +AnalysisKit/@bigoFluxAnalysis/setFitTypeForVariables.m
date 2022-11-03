function setFitTypeForVariables(obj,variables,fitTypes)
% setFitTypeForVariables  Set the fit types for variables
%   SETFITTYPEFORVARIABLES allows setting the fit type per variable of a
%   bigoFluxAnalysis array.
%
%   Syntax
%     SETFITTYPEFORVARIABLES(obj,variables,fitTypes)
%
%   Description
%     SETFITTYPEFORVARIABLES(obj,variables,fitTypes)  Sets the fit types for the
%       variables variables to fitTypes for bigoFluxAnalysis array obj. The
%       shapes of variables & fitTypes need to be compatible. Only unique
%       entries are allowed for variables.
%
%   Example(s)
%     SETFITTYPEFORVARIABLES(analysis,{'Oxygen','Nitrate'},'linear')  sets the 
%       fit type for all fits in the bigoFluxAnalysis array analysis that have
%       variable Oxygen or Nitrate to linear.
%     SETFITTYPEFORVARIABLES(analysis,{'Oxygen','Nitrate'},{'linear','poly2'})  
%       sets the fit type for all fits in the bigoFluxAnalysis array analysis 
%       that have variable Oxygen or Nitrate to linear and poly2 respectively.
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis
%       AnalysisKit.bigoFluxAnalysis array
%         An array of bigoFluxAnalyis instances for which the fit types should
%         be set.
%
%     variables - variables
%       char | cellstr
%         The variable name(s) for which to change the fit type(s) specified as
%         a char row vector or a cellstr. Its shape needs to be compatible with
%         the shape of fitTypes.
%
%     fitTypes - fit types
%       char | cellstr
%         The fit types specified as a char row vector or a cellstr. Its shape 
%         needs to be compatible with the shape of variables.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import UtilityKit.Utilities.arrayhom
    
    nObj = numel(obj);
    
    % Convert inputs to cellstr if they are char
    if ischar(variables)
        variables = cellstr(variables);
    end
    if ischar(fitTypes)
        fitTypes = cellstr(fitTypes);
    end
    
    % Validate data type
    dataType = class(variables);
    assert(iscellstr(variables),...
        'Dingi:AnalysisKit:bigoFluxAnalysis:setFitTypeForVariableS:InvalidType',...
        'Expected input number 2, variables, to be one of these types:\n\nchar, cellstr\n\nInstead its type was %s.',dataType)
    dataType = class(fitTypes);
    assert(iscellstr(fitTypes),...
        'Dingi:AnalysisKit:bigoFluxAnalysis:setFitTypeForVariableS:InvalidType',...
        'Expected input number 3, fitTypes, to be one of these types:\n\nchar, cellstr\n\nInstead its type was %s.',dataType)
    
    % Validate shape
    validateattributes(variables,{'cell'},{'vector'},mfilename,'variables',2)
    validateattributes(fitTypes,{'cell'},{'vector'},mfilename,'fitTypes',3)
    nVariables  = numel(variables);
    nFitTypes  = numel(fitTypes);
    assert(nFitTypes <= nVariables,...
        'Dingi:AnalysisKit:bigoFluxAnalysis:setFitTypeForVariableS:InvalidShape',...
        'Expected input number 3, fitTypes, to have less than or equal number of entries as input number 2, variables.')
    
    % Homogenize arrays
    [variables,fitTypes] = arrayhom(variables,fitTypes);
    
    % Check for unique variables
    nuVariables = numel(unique(variables));
    assert(nuVariables == nVariables,...
        'Dingi:AnalysisKit:bigoFluxAnalysis:setFitTypeForVariableS:NonUniqueVariables',...
        'Expected input number 2, variables, to have unique entries.')
    
    % Set fit types
    tbl         = obj.createFitTypesSummaryTable;
    [im,imInd]  = ismember(tbl{:,'Variable'},variables);
    ind         = tbl{:,'IndexFitTypes'};
    for oo = 1:nObj
        mask	= tbl{:,'IndexInstance'} == oo & ...
                  im;
        obj(oo).FitTypes(ind(mask)) = fitTypes(imInd(mask));
    end
end
