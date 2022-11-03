function setFitTypeForVariables(obj,variables,fitTypes)

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
