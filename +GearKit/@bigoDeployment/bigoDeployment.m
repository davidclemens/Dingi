classdef bigoDeployment < GearKit.gearDeployment
	properties
        chamber struct
        protocol table
    end
    
	methods
        function obj = bigoDeployment(path)
            
            if nargin == 0
                path        = char.empty;
                gearType    = char.empty;
            elseif nargin == 1
                gearType    = 'BIGO';
            else
                error('gearDeployment:bigoDeployment:wrongNumberOfInputs',...
                    'Wrong number of inputs.\n')
            end
            
            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType);
            
            obj     = determineChamberMetadata(obj);
            obj     = readProtocol(obj);
            obj     = readInternalSensors(obj);
            
            meanExperimentStart = mean(obj.protocol{obj.protocol{:,'Event'} == 'Experiment Start','Time'},'omitnan');
            meanExperimentEnd   = mean(obj.protocol{obj.protocol{:,'Event'} == 'Slide Down','StartTime'},'omitnan');
                                    
            obj.timeOfInterestStart     = meanExperimentStart;
            obj.timeOfInterestEnd       = meanExperimentEnd;
            
            obj     = readAuxillarySensors(obj);
            obj     = assignSensorMountingData(obj);
            obj     = calibrateSensors(obj);
            obj     = readAnalyticalSamples(obj);
        end
    end
    
   	% methods in seperate files
    methods (Access = public)
       	obj	= runAnalysis(obj)
        varargout = exportProtocol(obj,varargin)
    end
    
    methods (Access = protected)
        %custom subasign/subrefs
        %{
        function n = numArgumentsFromSubscript(obj,~,~)
        % overloading numArgumentsFromSubscript for the use in subsref and
        % subasign
            n = numel(obj);
        end
        function varargout = subsref(obj,s)
        % overloading subsref
            switch s(1).type
                case '{}'
                    nObj        = numel(obj);
                    varargout   = cell(1,nObj);
                    for ii = 1:nObj
                        [im,imInd]	= ismember(s.subs,obj(ii).dataInfo.name);
                        if any(~im)
                            error('sensor:subsref',...
                                  'The sensor ''%s'' holds no data called ''%s''\nAvailable data names are: %s.',obj.name,s.subs{find(~im,1)},strjoin(obj.dataInfo.name,', '))
                        else
                            varargout{ii}    = obj(ii).data(:,imInd);
                        end
                    end
                otherwise
                 	varargout	= {builtin('subsref',obj,s)};
            end
        end        
        function obj = subsasgn(obj,s,varargin)
        % overloading subasign
            switch s(1).type
                case '.'
                    obj = builtin('subsasgn',obj,s,varargin{:});
                case '()'
                    obj = builtin('subsasgn',obj,s,varargin{:});
                otherwise
                    error('sensor:subasign',...
                          'subasign not possible.')
            end
        end
        %}
        
        obj = readInternalSensors(obj)
        obj = determineChamberMetadata(obj)
        obj	= readProtocol(obj)        
    end 
end