classdef dataFlagger < handle
    
    properties
        FontName char = 'Helvetica'
        FontSize double = 12
        FontSizeLabelMultiplier	double = 1
        FontSizeTitleMultiplier	double = 1.5
    end
    properties %(Hidden)
        PanelOptionsWidth double = 250
        HeaderHeight double = 40
        FooterHeight double = 100
        Units char = 'pixel'
        FigurePosition double = [0 0 1920 1080]
        InnerMargin double = 5
        OuterMargin double = 10
        PanelLineWidth double = 1
        TickLength double = 5 
        FigureHandle matlab.ui.Figure
        AxesHandles
        PropertyLinks
        DataBrush
        ZoomAxis
        DeploymentsList
        VariablesList
        VariablesListInd
        FlagsList
        AxesPosition
        AxesCanvas
        HeaderCanvas
        FooterCanvas
    end
    properties (Dependent) %, Hidden
        NDeployments
        NVariables
        NFlags
        NSelectedDeployments
        NSelectedVariables
        NSelectedFlags
    end
    properties (SetObservable) %, Hidden
        GUIIsInitialized logical = false
        ModelIsInitialized logical = false
        AvailableVariables
        Deployments
        SelectedVariableIndices
        DeploymentIsSelected logical = true
        VariableIsSelected logical = true
        FlagIsSelected logical = true
    end
    
    methods
        function obj = dataFlagger(deployments,varargin)
            
            import internal.stats.parseArgs
            
            % Parse Name-Value pairs
%             optionName          = {}; % valid options (Name)
%             optionDefaultValue  = {}; % default value (Value)
%             [] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % Initialize model
            addlistener(obj,'Deployments','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);
            addlistener(obj,'AvailableVariables','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);
            addlistener(obj,'GUIIsInitialized','PostSet',@UIKit.GearDeploymentDataFlagger.dataFlagger.handlePropertyChangeEvents);
            
            obj.Deployments	= deployments(:);
            updateFlagsList(obj)
            
            obj.ModelIsInitialized  = true;
            
            % Setup the GUI
            initializeGUI(obj)
            
            obj.DataBrush = GraphKit.dataBrushWindow(obj.FigureHandle,...
                'BrushChangedFcn',      @UIKit.GearDeploymentDataFlagger.dataFlagger.handleBrushChangedEvent,...
                'EnableBrushing',       false);
        end
    end
    methods
        delete(obj)
        getAvailableVariables(obj)
        
        setDeploymentsListElements(obj,dst)
        setVariablesListElements(obj,dst)
        setFlagsListElements(obj,dst)
        
        updateVariablesList(obj)
        updateFlagsList(obj)
        
        selectVariables(obj)
        setBrushData(obj)
        saveFlagsToDisk(obj)
        setFlagForAllVariablesOfMeasurementdevice(obj)
    end
    methods (Access = private)
        initializeFigure(obj)
        initializeAxes(obj)
        initializeZoomAxis(obj)
        updateVariableAxes(obj)
        setStatusText(obj,str)
        applyFlags(obj,dpAll,iAll,jAll,dpBrushed,iBrushed,jBrushed)
    end
    
    % Get methods
    methods 
        function NDeployments = get.NDeployments(obj)
            NDeployments = numel(obj.Deployments);
        end
        function NVariables = get.NVariables(obj)
            NVariables = size(obj.VariablesList,1);
        end
        function NFlags = get.NFlags(obj)
            NFlags = size(obj.FlagsList,1);
        end
        function NSelectedDeployments = get.NSelectedDeployments(obj)
            NSelectedDeployments = sum(obj.DeploymentIsSelected);
        end
        function NSelectedVariables = get.NSelectedVariables(obj)
            NSelectedVariables = sum(obj.VariableIsSelected);
        end
        function NSelectedFlags = get.NSelectedFlags(obj)
            NSelectedFlags = sum(obj.FlagIsSelected);
        end
    end
    
    % Event handler methods
    methods (Static)
        handlePropertyChangeEvents(src,evnt)
        handleBrushChangedEvent(src,evnt)
    end
end