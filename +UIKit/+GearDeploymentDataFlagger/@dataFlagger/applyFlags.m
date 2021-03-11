function applyFlags(obj,dpAll,iAll,jAll,dpBrushed,iBrushed,jBrushed)


    % Flag to be set
    newFlag        = obj.FlagsList{obj.FlagIsSelected,'Flag'}.Id;

    % Set the selected flag to low for all array elements
    obj.Deployments(obj.DeploymentIsSelected).data    = setFlag(obj.Deployments(obj.DeploymentIsSelected).data,dpAll,iAll,jAll,newFlag,0);

    % Set the selected flag to high for all brushed array elements
    obj.Deployments(obj.DeploymentIsSelected).data    = setFlag(obj.Deployments(obj.DeploymentIsSelected).data,dpBrushed,iBrushed,jBrushed,newFlag,1);

end