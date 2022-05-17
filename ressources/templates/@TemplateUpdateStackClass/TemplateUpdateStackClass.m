classdef TemplateUpdateStackClass < handle
    % TemplateUpdateStackClass  Template class with update stack architecture
    % This is a template containing the framework needed for a class with an update
    % stack architecture, where properties have a front- and backend part and
    % updates/calculations are only performed if required.
    %
    % Copyright (c) 2022 David Clemens (dclemens@geomar.de)
    %
    
    % Properties that will influence the update stack if set. They are only set, if their value actually changes ('AbortSet').
    properties (SetObservable, AbortSet)
        % Influencing stack depth 1
        ObsProperty1
        
        % Influencing stack depth 2
        ObsProperty2
        ObsProperty3
        
        % Influencing stack depth 3
        ObsProperty4
    end

    % Frontend properties
    properties (Dependent)
        % Stack depth 1
        SD1propA

        % Stack depth 2
        SD2propA
        SD2propB

        % Stack depth 3
        SD3propA
    end

    % Backend properties
    properties (Access = 'private')
        % Stack depth 1
        SD1propA_

        % Stack depth 2
        SD2propA_
        SD2propB_

        % Stack depth 3
        SD3propA_
    end

    % The update stack's frontend
  	properties (Hidden, Dependent)
        UpdateStack double
    end
    
    % The update stacks backend
    properties (Access = 'private')
        UpdateStack_ (3,1) double = 2.*ones(3,1) % Initialize as 'update required'
    end

	methods
        function obj = TemplateUpdateStackClass()
            
            % Initialize listeners
            propertyList = {'ObsProperty1','ObsProperty2','ObsProperty3','ObsProperty4'};
            eventTypeList = {'PostSet','PostSet','PostSet','PostSet'};
            initializeUpdateStackListeners(obj,propertyList,eventTypeList)
        end
	end

    % Frontend/backend interface
    methods
        checkUpdateStack(obj,stackDepth)
        initializeUpdateStackListeners(obj,props,eventType)
    end

    % Frontend GET methods
    methods
        function updateStack = get.UpdateStack(obj)
            updateStack = obj.UpdateStack_;
        end

        % Stack depth 1
        function sD1propA = get.SD1propA(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            sD1propA = obj.SD1propA_;
        end

        % Stack depth 2
        function sD2propA = get.SD2propA(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            sD2propA = obj.SD2propA_;
        end
        function sD2propB = get.SD2propB(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            sD2propB = obj.SD2propB_;
        end

        % Stack depth 3
        function sD3propA = get.SD3propA(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            sD3propA = obj.SD3propA_;
        end
    end

    % Backend SET methods
    methods
        % Stack depth 1
        function obj = set.SD1propA(obj,value)
          	stackDepth      = 1;
            if ~isequal(obj.SD1propA_,value)
                obj.setUpdateStackToUpdating(stackDepth)
                obj.SD1propA_   = value;
                obj.setUpdateStackToUpdated(stackDepth)
            end
        end
        
        % Stack depth 2
        function obj = set.SD2propA(obj,value)
          	stackDepth      = 2;
            if ~isequal(obj.SD2propA_,value)
                obj.setUpdateStackToUpdating(stackDepth)
                obj.SD2propA_   = value;
                obj.setUpdateStackToUpdated(stackDepth)
            end
        end
        function obj = set.SD2propB(obj,value)
          	stackDepth      = 2;
            if ~isequal(obj.SD2propB_,value)
                obj.setUpdateStackToUpdating(stackDepth)
                obj.SD2propB_   = value;
                obj.setUpdateStackToUpdated(stackDepth)
            end
        end
        
        % Stack depth 3
        function obj = set.SD3propA(obj,value)
          	stackDepth      = 3;
            if ~isequal(obj.SD3propA_,value)
                obj.setUpdateStackToUpdating(stackDepth)
                obj.SD3propA_   = value;
                obj.setUpdateStackToUpdated(stackDepth)
            end
        end

        function obj = set.UpdateStack(obj,value)
            if ~isequal(obj.UpdateStack_,value)
                % If the UpdateStack is set (modified), set all stackDepths below the first change to 'UpdateRequired'
                updateStackDepth           	= find(diff(cat(2,obj.UpdateStack_,value),1,2) == 2,1); % Status changes from Updated to UpdateRequired
                value(updateStackDepth:end) = 2; % Set all stati downstream to UpdateRequired
                obj.UpdateStack_            = value;
            end
        end
    end

    % Methods called from checkUpdateStack
    methods (Access = private)
        
    end

    % Update stack event listener handler methods
    methods (Static)
        function handleUpdateStackListenerEvents(src,evnt)
            
            % If any of these properties change, they influences the update stack. Set the
            % stack accordingly.
            switch src.Name
                % Stack depth 1
                case 'ObsProperty1'
                    stackDepth  = 1;

                % Stack depth 2
                case 'ObsProperty2'
                    stackDepth  = 2;
                case 'ObsProperty3'
                    stackDepth  = 2;

                % Stack depth 3
                case 'ObsProperty4'
                    stackDepth  = 3;
            end
            % Set the update stack
            evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
        end
    end
end
