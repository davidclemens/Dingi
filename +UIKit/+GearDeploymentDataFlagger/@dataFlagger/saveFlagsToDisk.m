function saveFlagsToDisk(obj)

    % Set status text
    setStatusText(obj,'Saving to disk ...')
    
    for dep = 1:obj.NDeployments
        obj.Deployments(dep).MatFile.Properties.Writable = true;
        obj.Deployments(dep).MatFile.obj = obj.Deployments(dep);
        obj.Deployments(dep).MatFile.Properties.Writable = false;
    end
    
    % Set status text
    setStatusText(obj,'')
end