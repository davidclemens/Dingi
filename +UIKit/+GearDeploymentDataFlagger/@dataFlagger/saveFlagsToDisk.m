function saveFlagsToDisk(obj)
    
    import GearKit.gearDeployment
    % Set status text
    setStatusText(obj,'Saving to disk ...')
    
    for dep = 1:obj.NDeployments
        obj.Deployments(dep).save;
    end
    
    % Set status text
    setStatusText(obj,'')
end