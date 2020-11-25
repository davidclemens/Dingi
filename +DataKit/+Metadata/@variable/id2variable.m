function obj = id2variable(id)

	if ~isnumeric(id)
        error('DataKit:Metadata:variable:id2Variable:invalidDataType',...
            'The input argument ''id'' has to be numeric.')
	end
    
    variableListInfo    = DataKit.Metadata.variable.listAllVariableInfo();
    [im,imIdx]          = ismember(id,variableListInfo{:,'Id'});
    
    if ~all(im)
        error('DataKit:Metadata:variable:variableFromId:invalidVariableId',...
            'The variable id %u is invalid.',id(find(~im,1)))
    end
    
    obj     = variableListInfo{imIdx,'Variable'};
end