function selectVariables(obj)

    % Set status text
    setStatusText(obj,'Loading data ...')

    % Prepare data axes
    updateVariableAxes(obj)
    
    % Get index of selected variables
    selectedVariables   = find(obj.VariableIsSelected);
    
    RelativeTime        = 'h';
    
    % Initialize limits variables
	xLimits             = cell(obj.NVariables,1);
	yLimits             = NaN(obj.NVariables,2);
    
    % Loop over all selected variables
    for ax = 1:obj.NSelectedVariables
        % Get current variable index
        vv     = selectedVariables(ax);
        
        % Reset axis
        delete(obj.AxesHandles(vv).Children) % Delete all existing children
        obj.AxesHandles(vv).ColorOrderIndex = 1; % Reset ColorOrderIndex
        
        % Create logical index into the available variables
        maskAvailableVariables = obj.VariablesListInd == vv & ...
                                 obj.AvailableVariables{:,'ObjId'} == find(obj.DeploymentIsSelected);

        % Handle no data case
        if sum(maskAvailableVariables) == 0
            % Print no data label on axis
            text(obj.AxesHandles(vv),0.5,0.5,'no data',...
                'Units',        'normalized')
            
            % Set xlimits
            if isempty(xLimits{vv})
                xLimits{vv}	= obj.AxesHandles(vv).XLim;
            else
                xLimits{v}	= [nanmin([xLimits{vv}(1);obj.AxesHandles(vv).XLim(1)]),nanmax([xLimits{vv}(2);obj.AxesHandles(vv).XLim(2)])];
            end
            
            continue
        end
        
        % Get variable data
        data        = obj.Deployments(obj.DeploymentIsSelected).fetchData(obj.VariablesList{vv,'Id'},...
                        'RelativeTime',         RelativeTime,...
                        'GroupBy',              'Variable');
        
        % Initialize legend entries 
        legendEntries   = cell.empty;
        
        % Get number of returned data sources
        nSources        = size(data.DepData,1);

        % Loop over all data sources
        for src = 1:nSources
            % Get number of independent variables
            nIndepVariables     = numel(data.IndepData{src});

            if nIndepVariables > 1
                error('Dingi:GearKit:gearDeployment:markQualityFlags:TODO',...
                  'TODO: not implemented yet.')
            end

            % Assign data
            XData           = data.IndepData{src}{1};
            YData           = data.DepData{src};
            
            % Determine marker based on number of data points
            if numel(XData(:)) < 50
                marker  = 'o';
            elseif numel(XData(:)) < 1000
                marker  = '.';
            else
                marker  = 'none';
            end

            % Create display name. Add it to the legend entries.
            displayName     = char(data.DepInfo.MeasuringDevice(src));
            legendEntries  	= cat(1,legendEntries,{displayName});
            
            % Plot the data
            htmp = plot(obj.AxesHandles(vv),XData,YData,...
                'Tag',              displayName,...
                'UserData',         cat(2,data.DepInfo.PoolIdx(src),data.DepInfo.VariableIdx(src)),...
                'Marker',           marker,...
                'LineWidth',        1);
            htmp.MarkerFaceColor    = htmp.MarkerEdgeColor;
            
            % If a valid flag id is selected, set the brush data
            % accordingly.
            if obj.FlagsList{obj.FlagIsSelected,'Flag'}.Id > 0
                FData           = isFlag(data.Flags{src},char(obj.FlagsList{obj.FlagIsSelected,'Flag'}));
                htmp.BrushData  = double(FData');
            end

            % Update limits
            if isempty(xLimits{vv})
                xLimits{vv}      	= [nanmin(XData(:)),nanmax(XData(:))];
            else
                xLimits{vv}      	= [nanmin([xLimits{vv}(1);XData(:)]),nanmax([xLimits{vv}(2);XData(:)])];
            end
            yLimits(vv,:)	= [nanmin([yLimits(vv,1);YData(:)]),nanmax([yLimits(vv,2);YData(:)])];
        end
        
        % Create legend
        legend(obj.AxesHandles(vv),legendEntries,...
            'Location',         'best',...
            'FontName',         obj.FontName,...
            'FontSize',         obj.FontSize);
    end
    
    % Move the selected axes to the top of the uistack to enable zooming
    uistack(obj.AxesHandles(selectedVariables),'top');
    
    % Hide unnecessary x-axes
    set(obj.AxesHandles(selectedVariables(2:end)),...
        'XColor',    'none')
    % Show the bottom x-axis
    set(obj.AxesHandles(selectedVariables(1)),...
        'XColor',    'k')
    
    % Link the xlimits. Set limits.
    obj.PropertyLinks	= linkprop(obj.AxesHandles(selectedVariables),'XLim');
    xLimits             = cat(1,xLimits{selectedVariables});
    xLimitsGlobal       = [min(xLimits(:,1)),max(xLimits(:,2))];     
    set(obj.AxesHandles(selectedVariables),...
        'XLim',      xLimitsGlobal + 0.01.*[-1 1].*range(xLimitsGlobal))
    
    % Reposition axes to take up unused space
    optimizeAxesPosition(obj)
    
    % Set status text
    setStatusText(obj,'')
    
    function optimizeAxesPosition(df)
        
        tightInset  = get(df.AxesHandles(df.VariableIsSelected),{'TightInset'});
        tightInset  = cat(1,tightInset{:});
        
        tightInsetGlobal = max(tightInset,[],1);
        
        optimizedPosition = ...
            df.AxesPosition ...
            + [tightInsetGlobal(1),0,-sum(tightInsetGlobal([1,3])),0];
        optimizedPosition(:,4)  = ...
            (df.AxesCanvas(4) ...
             - (df.NSelectedVariables - 1)*df.InnerMargin ...
             - tightInsetGlobal(2))./df.NSelectedVariables;
        optimizedPosition(:,2)  = ...
            df.AxesCanvas(2) ...
            + tightInsetGlobal(2) ...
            + ((1:df.NSelectedVariables)' - 1).*(df.InnerMargin + optimizedPosition(1,4));
        
        set(df.AxesHandles(df.VariableIsSelected),...
            {'Position'},   num2cell(optimizedPosition,2))
    end
end