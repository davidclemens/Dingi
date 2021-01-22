classdef axesGroup < handle
% AXESGROUP groups and nests existing axes to reduce white space.
%   The AXESGROUP class arranges its children axes so that the white space
%   inbetween is removed. This results in overlapping axes if the actual
%   data within the axes allows it. The actual data will never overlap.
%
% AXESGROUP Properties:
%   Children - The children axes as axes array.
%   Parent - The figure handle of parent figure.
%   CommonAxis - The axis common to all axes of axesGroup.
%
% AXESGROUP Methods:
%    axesGroup - Constructs an axesGroup instance from existing axes handles.
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

% TODO:     [] handle reversed individual axes
%           [] handle DatetimeRuler, DurationRuler, CategoricalRuler &
%           Numeric Ruler

    properties
        Children % The children axes as axes array.
        Parent % The figure handle of parent figure.
        CommonAxis = 'XAxis' % The axis common to all axes of axesGroup.
    end
    properties %(Hidden)
        IsInitialized = false
        CommonAxesLink
        CommonAxesData % axes index, value
        IndividualAxesData % axes index, value
    end
    properties (Dependent) % Hidden
        CommonAxesIndex
        CommonAxesDataLimits
        CommonAxesDataLimitsDouble
        CommonAxesSize % (cm)
        CommonAxesDirection
        CommonAxesIsDatetime
        CommonAxesRulerType
        IndividualAxis
        IndividualAxesIndex
        IndividualAxesDataLimits
        IndividualAxesDataLimitsDouble
        IndividualAxesLength % (cm)
        IndividualAxesEnvelope % common axis bins, axes, min/max (cm)
        IndividualAxesEnvelopeInset % left, bottom, right, top (cm)
        IndividualAxesDirection
        IndividualAxesIsDatetime
        IndividualAxesRulerType
        XAxesN
        YAxesN
        NAxes
        SubplotIndices
        FigurePosition % x, y, width, height (cm)
        AxesPositionCurrent % x, y, width, height (cm)
        AxesPosition % x, y, width, height (cm)
        AxesTightInsetCurrent % left, bottom, right, top (cm)
        AxesPositionDelta
        AxesNoData
    end
    properties (Constant) % Hidden
        validCommonAxis = {'XAxis','YAxis'};
        CommonAxesEnvelopeBinCount = 60;
        FigureOuterMargin = 0.5.*ones(1,4) % left, bottom, right, top (cm)
        FigureInnerMargin = 0.5 % (cm)
    end

    methods
        function obj = axesGroup(hax,varargin)      
        % AXESGROUP Constructs an axesGroup instance from existing axes handles.
        %   Create a axesGroup object from existing axes handles.
        %
        % Syntax
        %   axesGroup = AXESGROUP(hax)
        %   axesGroup = AXESGROUP(__,Name,Value)
        %
        %
        % Description
        %   axesGroup = AXESGROUP(hax) creates an axesGroup instance from the axes
        %       handles hax.
        %
        %   axesGroup = AXESGROUP(__,Name,Value) specifies additional parameters
        %       for the NortekInstrumentFile using one or more name-value pair
        %       arguments as listed below.
        %
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   hax - axes handles
        %       Axes array
        %       Array of axes handles to the axes to be included in the axesGroup
        %       object.
        %
        %
        % Name-Value Pair Arguments
        %	CommonAxis - Axis common to all axes included in the axesGroup
        %       'XAxis' (default) | 'YAxis'
        %           Sets which axis is common to all axes in the axesGroup.
        %
        % 
        % See also AXES
        %
        % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

            % parse Name-Value pairs
            optionName          = {'CommonAxis'}; % valid options (Name)
            optionDefaultValue  = {'XAxis'}; % default value (Value)
            [CommonAxis...
             ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            obj.Children    = hax;
            obj.CommonAxis  = CommonAxis;

            obj = initialize(obj);

            drawNow(obj);
        end


        % set methods
        function obj = set.CommonAxis(obj,value)
            obj.CommonAxis = validatestring(value,obj.validCommonAxis);
            obj = initialize(obj);
            drawNow(obj);
        end

        % get methods
        function CommonAxesIndex = get.CommonAxesIndex(obj)
            switch obj.CommonAxis
                case 'XAxis'
                    CommonAxesIndex = 1;
                case 'YAxis'
                    CommonAxesIndex = 2;
            end
        end
        function IndividualAxis = get.IndividualAxis(obj)
            switch obj.CommonAxis
                case 'XAxis'
                    IndividualAxis = 'YAxis';
                case 'YAxis'
                    IndividualAxis = 'XAxis';
            end
        end
        function IndividualAxesIndex = get.IndividualAxesIndex(obj)
            switch obj.CommonAxis
                case 'XAxis'
                    IndividualAxesIndex = 2;
                case 'YAxis'
                    IndividualAxesIndex = 1;
            end
        end
        function NAxes = get.NAxes(obj)
            NAxes = numel(obj.Children);
        end
        function XAxesN = get.XAxesN(obj)
            if obj.CommonAxesIndex == 1
                XAxesN = 1;
            else
                XAxesN = obj.NAxes;
            end
        end
        function YAxesN = get.YAxesN(obj)
            if obj.CommonAxesIndex == 2
                YAxesN = 1;
            else
                YAxesN = obj.NAxes;
            end
        end
        function SubplotIndices = get.SubplotIndices(obj)
            SubplotIndices = reshape(1:obj.NAxes,obj.XAxesN,obj.YAxesN)';
        end
        function CommonAxesDataLimitsDouble = get.CommonAxesDataLimitsDouble(obj)
%          	CommonAxesDataLimitsDouble = [nanmin(obj.CommonAxesData(:,2)),nanmax(obj.CommonAxesData(:,2))];
            
            CommonAxesDataLimitsDouble = cat(2,...
                accumarray(obj.CommonAxesData(:,1),obj.CommonAxesData(:,2),[],@nanmin,NaN),...
                accumarray(obj.CommonAxesData(:,1),obj.CommonAxesData(:,2),[],@nanmax,NaN));
        end
        function CommonAxesDataLimits = get.CommonAxesDataLimits(obj)
         	CommonAxesDataLimits = num2cell(obj.CommonAxesDataLimitsDouble,2);
            
            isDatetimeRuler = obj.CommonAxesRulerType == 'DatetimeRuler';
            CommonAxesDataLimits(isDatetimeRuler) = cellfun(@(c) datetime(c,'ConvertFrom','datenum'),CommonAxesDataLimits(isDatetimeRuler),'un',0);
        end
        function IndividualAxesDataLimitsDouble = get.IndividualAxesDataLimitsDouble(obj)
            IndividualAxesDataLimitsDouble = cat(2,...
                accumarray(obj.IndividualAxesData(:,1),obj.IndividualAxesData(:,2),[],@nanmin,NaN),...
                accumarray(obj.IndividualAxesData(:,1),obj.IndividualAxesData(:,2),[],@nanmax,NaN));
        end
        function IndividualAxesDataLimits = get.IndividualAxesDataLimits(obj)
            IndividualAxesDataLimits = num2cell(obj.IndividualAxesDataLimitsDouble,2);
            
            isDatetimeRuler = obj.IndividualAxesRulerType == 'DatetimeRuler';
            IndividualAxesDataLimits(isDatetimeRuler) = cellfun(@(c) datetime(c,'ConvertFrom','datenum'),IndividualAxesDataLimits(isDatetimeRuler),'un',0);
        end
        function IndividualAxesEnvelope = get.IndividualAxesEnvelope(obj)
            IndividualAxesEnvelope = calculateAxesEnvelope(obj);
        end
        function IndividualAxesEnvelopeInset = get.IndividualAxesEnvelopeInset(obj)
            IndividualAxesEnvelopeInset = zeros(obj.CommonAxesEnvelopeBinCount,obj.NAxes - 1);
            switch obj.CommonAxis
                case 'XAxis'
                    IndividualAxesEnvelopeInset = nanmin( ...
                                                        obj.IndividualAxesEnvelope(:,1:end - 1,1) ...
                                                      + obj.IndividualAxesEnvelope(:,2:end,2) ...
                                                  )';
                case 'YAxis'
                    IndividualAxesEnvelopeInset = nanmin( ...
                                                        obj.IndividualAxesEnvelope(:,2:end,1) ...
                                                      + obj.IndividualAxesEnvelope(:,1:end - 1,2) ...
                                                  )';
            end
        end
        function Parent = get.Parent(obj)
            if obj.NAxes > 0
                Parent = obj.Children(1).Parent;
            else
                Parent = gobjects();
            end
        end
        function FigurePosition = get.FigurePosition(obj)
            currentUnits        = obj.Parent.Units;
            obj.Parent.Units    = 'centimeters';
            FigurePosition  	= get(obj.Parent,'Position');
            obj.Parent.Units    = currentUnits;
        end
        function AxesPositionCurrent = get.AxesPositionCurrent(obj)
            if obj.NAxes > 0
                currentUnits        = get(obj.Children,{'Units'});
                set(obj.Children,{'Units'},{'centimeters'});
                AxesPositionCurrent = get(obj.Children,'Position');
                set(obj.Children,{'Units'},currentUnits);
                AxesPositionCurrent	= cat(1,AxesPositionCurrent{:});
            else
                AxesPositionCurrent = [];
            end
        end
        function AxesTightInsetCurrent = get.AxesTightInsetCurrent(obj)
            if obj.NAxes > 0
                currentUnits            = get(obj.Children,{'Units'});
                set(obj.Children,{'Units'},{'centimeters'});
                AxesTightInsetCurrent	= get(obj.Children,'TightInset');
                set(obj.Children,{'Units'},currentUnits);
                AxesTightInsetCurrent	= cat(1,AxesTightInsetCurrent{:});
            else
                AxesTightInsetCurrent	= [];
            end
        end
        function IndividualAxesLength = get.IndividualAxesLength(obj)
            switch obj.CommonAxis
                case 'XAxis'
                    IndividualAxesLength	= (obj.FigurePosition(4) ...
                                               - sum(obj.FigureOuterMargin([2,4])) ...
                                               - (obj.NAxes - 1).*obj.FigureInnerMargin ...
                                               - sum(reshape(obj.AxesTightInsetCurrent(:,[2,4]),[],1)) ...
                                               + sum(obj.IndividualAxesEnvelopeInset) ...
                                              )/obj.NAxes;
                case 'YAxis'
                    IndividualAxesLength    = (obj.FigurePosition(3) ...
                                               - sum(obj.FigureOuterMargin([1,3])) ...
                                               - (obj.NAxes - 1).*obj.FigureInnerMargin ...
                                               - sum(reshape(obj.AxesTightInsetCurrent(:,[1,3]),[],1)) ...
                                               + sum(obj.IndividualAxesEnvelopeInset) ...
                                              )/obj.NAxes;
            end
        end
        function AxesPosition = get.AxesPosition(obj)
            AxesPosition    = NaN(obj.NAxes,4);
            switch obj.CommonAxis
                case 'XAxis'
                    AxesPosition(:,1)	= obj.FigureOuterMargin(1) ...
                                          + max(obj.AxesTightInsetCurrent(:,1));
                    AxesPosition(:,2)   = flipud( ...
                                                obj.FigureOuterMargin(2) ...
                                              + cumsum(flipud(obj.AxesTightInsetCurrent(:,2))) ...
                                              + obj.IndividualAxesLength.*(0:(obj.NAxes - 1))' ...
                                              + cumsum(flipud([obj.AxesTightInsetCurrent(2:end,4);0])) ...
                                              + obj.FigureInnerMargin.*(0:(obj.NAxes - 1))' ...
                                              - cumsum([0;flipud(obj.IndividualAxesEnvelopeInset)]) ...
                                          );
                    AxesPosition(:,3)   = obj.FigurePosition(3) ...
                                          - sum(obj.FigureOuterMargin([1,3])) ...
                                          - max(obj.AxesTightInsetCurrent(:,1)) ...
                                          - max(obj.AxesTightInsetCurrent(:,3));
                    AxesPosition(:,4)   = obj.IndividualAxesLength;
                case 'YAxis'
                    AxesPosition(:,1)   = obj.FigureOuterMargin(1) ...
                                          + cumsum(obj.AxesTightInsetCurrent(:,1)) ...
                                          + obj.IndividualAxesLength.*(0:(obj.NAxes - 1))' ...
                                          + cumsum([0;obj.AxesTightInsetCurrent(1:end - 1,3)]) ...
                                          + obj.FigureInnerMargin.*(0:(obj.NAxes - 1))' ...
                                          - cumsum([0;obj.IndividualAxesEnvelopeInset]);
                    AxesPosition(:,2) 	= obj.FigureOuterMargin(1) ...
                                          + max(obj.AxesTightInsetCurrent(:,2));
                    AxesPosition(:,3)   = obj.IndividualAxesLength;
                 	AxesPosition(:,4)   = obj.FigurePosition(4) ...
                                          - sum(obj.FigureOuterMargin([2,4])) ...
                                          - max(obj.AxesTightInsetCurrent(:,2)) ...
                                          - max(obj.AxesTightInsetCurrent(:,4));

            end
        end
        function AxesPositionDelta = get.AxesPositionDelta(obj)
            AxesPositionDelta = max(reshape(abs(obj.AxesPositionCurrent - obj.AxesPosition)./obj.AxesPosition,[],1));
        end
        function CommonAxesDirection = get.CommonAxesDirection(obj)
            CommonAxesDirection = get(obj.Children(1),[obj.CommonAxis(1),'Dir']);
        end
        function IndividualAxesDirection = get.IndividualAxesDirection(obj)
            IndividualAxesDirection = get(obj.Children,{[obj.IndividualAxis(1),'Dir']});
        end
        function CommonAxesRulerType = get.CommonAxesRulerType(obj)
            rulerObjects        = get(obj.Children,obj.CommonAxis);
            CommonAxesRulerType = categorical(regexprep(cellfun(@class,rulerObjects,'un',0),'matlab.graphics.axis.decorator.',''));
%             CommonAxesRulerType = CommonAxesRulerType(1);
        end
        function IndividualAxesRulerType = get.IndividualAxesRulerType(obj)
            rulerObjects            = get(obj.Children,obj.IndividualAxis);
            IndividualAxesRulerType = categorical(regexprep(cellfun(@class,rulerObjects,'un',0),'matlab.graphics.axis.decorator.',''));
        end
        function AxesNoData = get.AxesNoData(obj)
            AxesNoData = cellfun(@isempty,get(obj.Children,'Children'));
        end
        


        % functions in other files
        obj = initialize(obj)
        obj = initializeAxesAppearance(obj)
        drawNow(obj)
        obj = getAxesData(obj)
        obj = linkCommonAxes(obj)
        envelope = calculateAxesEnvelope(obj)
        y = dataUnits2Centimeters(x,dataLimits,lengthLimits)
        callbackFigureSizeChanged(obj,src,~)
    end
end
