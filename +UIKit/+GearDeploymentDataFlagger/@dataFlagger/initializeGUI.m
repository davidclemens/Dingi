function initializeGUI(obj)
    
    % Extract properties from the data flagger
    units           = obj.Units;
    figurePosition  = obj.FigurePosition;
    innerMargin     = obj.InnerMargin;
    outerMargin     = obj.OuterMargin;
    panelLineWidth  = obj.PanelLineWidth;
    
    fontName      	= obj.FontName;
    fontSize      	= obj.FontSize;
    
    % Calculate the position of the options panel
    panelOptionsWidth       = obj.PanelOptionsWidth;
    panelOptionsHeight      = figurePosition(4) - 2*outerMargin;
    panelOptionsPosition    = [...
        figurePosition(3) - outerMargin - panelOptionsWidth,...
        outerMargin,...
        panelOptionsWidth,...
        panelOptionsHeight];
    
    % Calculate the positions of the subpanels
    panelDeploymentWidth    = panelOptionsWidth - 2*panelLineWidth - 2*innerMargin;
    panelDeploymentHeight   = (panelOptionsHeight - 2*panelLineWidth - 4*innerMargin - 8*panelLineWidth)/3;
    
    panelVariablesWidth     = panelDeploymentWidth;
    panelVariablesHeight    = panelDeploymentHeight;
    
    panelFlagsWidth         = panelDeploymentWidth;
    panelFlagsHeight        = panelDeploymentHeight;
    
    panelDeploymentPosition = [...
        innerMargin,...
        3*innerMargin + panelVariablesHeight + panelFlagsHeight,...
        panelDeploymentWidth,...
        panelDeploymentHeight];
    
    panelVariablesPosition = [...
        innerMargin,...
        2*innerMargin + panelFlagsHeight,...
        panelVariablesWidth,...
        panelVariablesHeight];
    
    panelFlagsPosition = [...
        innerMargin,...
        innerMargin,...
        panelFlagsWidth,...
        panelFlagsHeight];
    
    
    % Create GUI window
    obj.FigureHandle = figure(...
        'Tag',                  'GUI',...
        'Name',                 'Data Flagger',...
        'Units',                units,...
        'Position',             figurePosition,...
        'Interruptible',        'on',...
        'UserData',             struct('dataFlagger',obj),...
        'MenuBar',              'none',...
        'ToolBar',              'figure',...
        'CloseRequestFcn',      {@deleteFcn,obj});
    
    % Get the handle of the standard toolbar
    hToolbar = findall(obj.FigureHandle,'Type','uitoolbar');
    set(hToolbar,...
        'Tag',                  'Toolbar')
    
    % Delete unecessary toolbar elements
    delete(findall(obj.FigureHandle,...
                   {'Type',         'uipushtool',...
        '-or',      'Type',         'uitoggletool'},...
        '-regexp',  'Tag',          '(Standard\.|Annotation\.|Plottools\.|DataManager\.|\.Rotate)'))
    
    % Add menubar
    hMenuFile = uimenu(obj.FigureHandle,...
        'Tag',                  'MenuFile',...
        'Label',                'File');
        % Create menu: File > Close
        hMenuFileChildren(1) = uimenu(hMenuFile,...
            'Tag',                  'MenuFileClose',...
            'Label',                'Close',...
            'Accelerator',          'W',...
            'MenuSelectedFcn',      {@menuSelectedFcn,obj});
    hMenuBrush = uimenu(obj.FigureHandle,...
        'Tag',                  'MenuBrush',...
        'Label',                'Brush');
        % Create menu: Brush > Toggle
        hMenuFileChildren(1) = uimenu(hMenuBrush,...
            'Tag',                  'MenuBrushToggleMode',...
            'Label',                'Brush On/Off',...
            'Accelerator',          'B',...
            'MenuSelectedFcn',      {@menuSelectedFcn,obj});
        % Create menu: Brush > Save to disk
        hMenuFileChildren(2) = uimenu(hMenuBrush,...
            'Tag',                  'MenuBrushSave',...
            'Label',                'Save to disk',...
            'Accelerator',          'S',...
            'MenuSelectedFcn',      {@menuSelectedFcn,obj});
        
	% Add context menu
    hContextMenu = uicontextmenu(obj.FigureHandle,...
        'Tag',          'AxesContextMenu');
        hContextMenuTree(1) = uimenu(hContextMenu,...
            'Tag',          'ApplyFlagToMeasuringDevice',...
            'Text',         'Apply flag to measuring device',...
            'Callback',     {@contextMenuSelectedFcn,obj});
    
    % Add GUI elements
    % Add the options panel
    hPanelOpts = uipanel(obj.FigureHandle,...
        'Tag',          'PanelOptions',...
        'Title',        'Options',...
        'Units',        units,...
        'Position',     panelOptionsPosition,...
        'FontName',   	fontName,...
        'FontSize',     fontSize);
        % Add the deployments subpanel
        hPanelDeployments = uipanel(hPanelOpts,...
            'Tag',          'PanelDeployments',...
            'Title',        'Deployments',...
            'Units',        units,...
            'Position',     panelDeploymentPosition,...
            'FontName',   	fontName,...
            'FontSize',     fontSize);
            % Add the deployments list box
            hListBoxDeployments = uicontrol(hPanelDeployments,...
                'Style',        'listbox',...
                'Tag',          'ListBoxDeployments',...
                'Units',        units,...
                'Position',     [0,-1,panelDeploymentPosition(3:4) - [0,20]],...
                'FontName',   	fontName,...
                'FontSize',     fontSize,...
                'Min',          1,...
                'Max',          1,...
                'String',       {'<none>'},...
                'CreateFcn',    {@createFcn,obj},...
                'Callback',     {@callbackFcn,obj});
        % Add the variables subpanel
        hPanelVariables = uipanel(hPanelOpts,...
            'Tag',          'PanelVariables',...
            'Title',        'Variables',...
            'Units',        units,...
            'Position',     panelVariablesPosition,...
            'FontName',     fontName,...
            'FontSize',     fontSize);
            % Add the variables list box
            hListBoxVariables = uicontrol(hPanelVariables,...
                'Style',        'listbox',...
                'Tag',          'ListBoxVariables',...
                'Units',        units,...
                'Position',     [0,-1,panelVariablesPosition(3:4) - [0,20]],...
                'FontName',   	fontName,...
                'FontSize',     fontSize,...
                'Min',          0,...
                'Max',          Inf,...
                'String',       {'<none>'},...
                'CreateFcn',    {@createFcn,obj},...
                'Callback',     {@callbackFcn,obj});
        % Add the flags subpanel
        hPanelFlags = uipanel(hPanelOpts,...
            'Tag',          'PanelFlags',...
            'Title',        'Flags',...
            'Units',        units,...
            'Position',     panelFlagsPosition,...
            'FontName',  	fontName,...
            'FontSize',     fontSize);
            % Add the flags list box
            hListBoxFlags = uicontrol(hPanelFlags,...
                'Style',        'listbox',...
                'Tag',          'ListBoxFlags',...
                'Units',        units,...
                'Position',     [0,-1,panelFlagsPosition(3:4) - [0,20]],...
                'FontName',   	fontName,...
                'FontSize',     fontSize,...
                'Min',          0,...
                'Max',          Inf,...
                'String',       {'<none>'},...
                'CreateFcn',    {@createFcn,obj},...
                'Callback',     {@callbackFcn,obj});
            
	% Initialize header
    initializeHeader(obj)
    
	% Initialize the data axes
    initializeAxes(obj)

    % Initialize zoom axis
    initializeZoomAxis(obj)
    
    % Set the GUIIsInitialized flag
	obj.GUIIsInitialized    = true;
    

    function createFcn(src,~,df)
  	% Executes after GUI element object creation, after setting all properties.
        switch src.Tag
            case 'ListBoxDeployments'
                % Initialize the list box elements
                setDeploymentsListElements(df,src)
                % Update the selection in the model
                setSelection(df,'DeploymentIsSelected',[df.NDeployments,1],src.Value)
            case 'ListBoxVariables'
                % Initialize the list box elements
                setVariablesListElements(df,src)
                % Update the selection in the model
                setSelection(df,'VariableIsSelected',[df.NVariables,1],src.Value)
            case 'ListBoxFlags'
                % Initialize the list box elements
                setFlagsListElements(df,src)
                % Update the selection in the model
                setSelection(df,'FlagIsSelected',[df.NFlags,1],src.Value)
        end
    end

    function callbackFcn(src,~,df)
  	% Executes on selection change in the GUI list boxes.
        switch src.Tag
            case 'ListBoxDeployments'
                % Update the selection in the model
                setSelection(df,'DeploymentIsSelected',[df.NDeployments,1],src.Value)
            case 'ListBoxVariables'
                % Update the selection in the model
                setSelection(df,'VariableIsSelected',[df.NVariables,1],src.Value)
            case 'ListBoxFlags'
                % Update the selection in the model
                setSelection(df,'FlagIsSelected',[df.NFlags,1],src.Value)
        end
    end

    function setSelection(df,prop,sz,ind)
    % Converts the selection index into a logical indexing array and
    % updates the model if changes to the selection occurred
    
        % Convert the selection index into a logical indexing array
        mask    = createSelectionMask(sz,ind);
        
        % Only set the selection in the model, if it differs from the
        % current one. This avoids triggering listeners at every click in
        % the listboxes.
        if ~isequal(df.(prop),mask)
            df.(prop) = mask;
        end
        
        function mask = createSelectionMask(sz,ind)
            mask        = false(sz);
            mask(ind)   = true;
        end
    end

    function menuSelectedFcn(src,~,df)
	% Executes on menu selection
        switch src.Tag
            case 'MenuFileClose'
                % Close the GUI
                close(df.FigureHandle)
            case 'MenuBrushSave'
                % Save the deployment instances to disk
                saveFlagsToDisk(df)
            case 'MenuBrushToggleMode'
                % Toggle the brush mode
                if df.DataBrush.EnableBrushing
                    df.DataBrush.EnableBrushing = false;
                else
                    df.DataBrush.EnableBrushing = true;
                end
        end
    end

    function contextMenuSelectedFcn(src,evnt,df)
	% Executes on menu selection
        switch src.Tag
            case 'ApplyFlagToMeasuringDevice'
                % Apply current flag to all variables of the measurement
                % device
                df.setFlagForAllVariablesOfMeasurementdevice;
        end
    end

    function deleteFcn(src,~,df)
    % Executes on object deletion
        switch src.Tag
            case 'GUI'
                % Present a modal dialog if deletion of the GUI is
                % requested.
                
                % Get screen pixel density
                gr              = groot;
                dpi             = gr.ScreenPixelsPerInch;
                
                % Define the layout measurements depending on the font size
                margin          = 10;
                heightButton    = 2*margin + df.FontSize/72*dpi;
                width           = 350;
                height          = 2*heightButton + 3*margin;
                nButtons        = 3;
                widthButton     = (width - (nButtons + 1)*margin)/nButtons;
                
                % Create the dialog box
                hDlg = dialog(...
                    'Tag',          'ModalClose',...
                    'Position',     [df.FigureHandle.Position(1:2) + 0.5.*df.FigureHandle.Position(3:4),width,height],...
                    'Name',         'Close');
                
                % Create the text prompt
                txt = uicontrol(hDlg,...
                 	'Style',                'text',...
                    'Tag',                  'ModalText',...
                    'Position',             [margin, 2*margin + heightButton, width - 2*margin, height - 3*margin - heightButton],...
                    'String',            	'Do you want to save to disk before closing?',...
                    'HorizontalAlignment',  'left',...
                    'FontName',             df.FontName,...
                    'FontSize',             df.FontSize);
                
                % Create 3 push buttons
                btnLabels       = {'Save','Close','Cancel'};
                btnTags         = {'ModalSave','ModalClose','ModalCancel'};
                for btn = 1:nButtons
                    hBtn(btn,1) = uicontrol(hDlg,...
                        'Style',        'pushbutton',...
                        'Tag',          btnTags{btn},...
                        'Position',     [margin + (btn - 1)*(widthButton + margin),margin,widthButton,heightButton],...
                        'String',       btnLabels{btn},...
                        'Callback',     {@modalBtn,df},...
                        'FontName',     df.FontName,...
                        'FontSize',     df.FontSize);
                end
        end
    end

    function modalBtn(src,~,df)
    % Executes on modal dialog button push
        switch src.Tag
            case 'ModalSave'
                % Save 
                saveFlagsToDisk(df)
                
                % Close the modal dialogue
                close(src.Parent)
                
                % Close the GUI
                delete(df.FigureHandle)
            case 'ModalClose'
                % Close the modal dialogue
                close(src.Parent)
                
                % Close the GUI
                delete(df.FigureHandle)
            case 'ModalCancel'
                % Close the modal dialogue
                close(src.Parent)
        end
    end
end