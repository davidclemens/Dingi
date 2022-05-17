function updateVariablesList(obj)

    % Get unique dependent-independent variable combinations
    [uVariable,uInd1,uInd]	= unique(cat(2,obj.AvailableVariables(:,'Id'),table(cellfun(@num2str,obj.AvailableVariables{:,'IndependentVariableId'},'un',0))),'rows');
    uVariable            	= cat(2,uVariable(:,1),obj.AvailableVariables(uInd1,{'IndependentVariableId','IndependentVariable'}));
    nU                      = size(uVariable,1);
    
    isInSelectedDeployment          = obj.AvailableVariables{:,'ObjId'} == find(obj.DeploymentIsSelected);
    variableIsInSelectedDeployment  = accumarray(uInd(isInSelectedDeployment),true(sum(isInSelectedDeployment),1),[nU,1]) > 0;
    
    marker  = repmat({'*** '},nU,1);
    marker(variableIsInSelectedDeployment) = {''};
    
    

    % list information about those combinations
    [~,variableInfo]  	= DataKit.Metadata.variable.validate('Id',uVariable{:,'Id'});
    variableInfo        = struct2table(variableInfo);
    
    variableInfo    = cat(2,obj.AvailableVariables(uInd1,:),variableInfo(:,{'Abbreviation','Symbol','Name'}));
    variableInfo{:,'IndependentVariableLabel'}   = cellfun(@(iv) strjoin({iv(:).Abbreviation},', '),variableInfo{:,'IndependentVariable'},'un',0);
    
    obj.VariablesList       = variableInfo;
    obj.VariablesListInd    = uInd;
    obj.VariablesList.Label = strcat(marker,variableInfo{:,'Abbreviation'},{' ('},variableInfo{:,'IndependentVariableLabel'},{')'});
    obj.VariablesList.Tag   = strtrim(cellstr(num2str(variableInfo{:,'Id'})));
    
    hListBox    = findobj(obj.FigureHandle,'Tag','ListBoxVariables');
    if ~isempty(hListBox)
        hListBox.String     = obj.VariablesList.Label;
    end
end