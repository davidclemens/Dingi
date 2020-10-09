classdef axesGroup < handle

    % TODO: handle reversed individual axes

    properties
        Children
        Parent
        CommonAxis = 'XAxis'
    end
    properties %(Hidden)
        IsInitialized = false
        CommonAxesLink
        CommonAxesData % axes index, value
        IndividualAxesData % axes index, value
        CommonAxesIsDatetime
        IndividualAxesIsDatetime
    end
    properties (Dependent) % Hidden
        CommonAxesIndex
        CommonAxesDataLimits
        CommonAxesSize % (cm)
        CommonAxesDirection
        IndividualAxis
        IndividualAxesIndex
        IndividualAxesDataLimits
        IndividualAxesLength % (cm)
        IndividualAxesEnvelope % common axis bins, axes, min/max (cm)
        IndividualAxesEnvelopeInset % left, bottom, right, top (cm)
        IndividualAxesDirection
        XAxesN
        YAxesN
        NAxes
        SubplotIndices
        FigurePosition % x, y, width, height (cm)
        AxesPositionCurrent % x, y, width, height (cm)
        AxesPosition % x, y, width, height (cm)
        AxesTightInsetCurrent % left, bottom, right, top (cm)
        AxesPositionDelta
    end
    properties (Constant) % Hidden
        validCommonAxis = {'XAxis','YAxis'};
        CommonAxesEnvelopeBinCount = 60;
        FigureOuterMargin = 0.5.*ones(1,4) % left, bottom, right, top (cm)
        FigureInnerMargin = 0.5 % (cm)
    end

    methods
        function obj = axesGroup(hax,varargin)
            % AXESGROUP

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
        function CommonAxesDataLimits = get.CommonAxesDataLimits(obj)
            CommonAxesDataLimits = [nanmin(obj.CommonAxesData(:,2)),nanmax(obj.CommonAxesData(:,2))];
            if obj.CommonAxesIsDatetime
                CommonAxesDataLimits = datetime(CommonAxesDataLimits,'ConvertFrom','datenum');
            end
        end
        function IndividualAxesDataLimits = get.IndividualAxesDataLimits(obj)
            IndividualAxesDataLimits = cat(2,...
                accumarray(obj.IndividualAxesData(:,1),obj.IndividualAxesData(:,2),[],@nanmin,NaN),...
                accumarray(obj.IndividualAxesData(:,1),obj.IndividualAxesData(:,2),[],@nanmax,NaN));

            if obj.IndividualAxesIsDatetime
                IndividualAxesDataLimits = datetime(IndividualAxesDataLimits,'ConvertFrom','datenum');
            end
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
