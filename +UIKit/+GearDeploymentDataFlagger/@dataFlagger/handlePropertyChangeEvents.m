function handlePropertyChangeEvents(src,evnt)
            
    % Update model
    switch src.Name
        case 'GUIIsInitialized'
            % Add property listeners
            addlistener(evnt.AffectedObject,'DeploymentIsSelected','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);
            addlistener(evnt.AffectedObject,'VariableIsSelected','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);
            addlistener(evnt.AffectedObject,'FlagIsSelected','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);

            if evnt.AffectedObject.ModelIsInitialized
                selectVariables(evnt.AffectedObject)
                setStatusText(evnt.AffectedObject,'')
            end
        case 'Deployments'
            getAvailableVariables(evnt.AffectedObject)
        case 'AvailableVariables'
            updateVariablesList(evnt.AffectedObject)
        case 'DeploymentIsSelected'
            updateVariablesList(evnt.AffectedObject)                    
    end

    % Update GUI
    if evnt.AffectedObject.GUIIsInitialized
        switch src.Name
            case 'Deployments'
                setDeploymentsListElements(evnt.AffectedObject)
            case 'DeploymentIsSelected'
                setVariablesListElements(evnt.AffectedObject)
                selectVariables(evnt.AffectedObject)
            case 'VariableIsSelected'
                selectVariables(evnt.AffectedObject)
            case 'FlagIsSelected'
                setBrushData(evnt.AffectedObject)
        end
    end
end