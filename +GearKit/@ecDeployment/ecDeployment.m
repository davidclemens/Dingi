classdef ecDeployment < GearKit.gearDeployment
% ECDEPLOYMENT Represents a Geomar BIGO deployment
%	The ECDEPLOYMENT class reads all data related to a single Geomar EC
%	deployment. The resulting object has plot, analysis and export methods.
%
% ECDEPLOYMENT Properties:
%
% ECDEPLOYMENT Methods:
%	ecDeployment - 
%
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

	properties
    end
    
	methods
        function obj = ecDeployment(path)
            
            if nargin == 0
                path        = char.empty;
                gearType    = char.empty;
            elseif nargin == 1
                gearType    = 'EC';
            else
                error('GearKit:gearDeployment:ecDeployment:wrongNumberOfInputs',...
                    'Wrong number of inputs.\n')
            end
            
            % call superclass constructor
            obj     = obj@GearKit.gearDeployment(path,gearType);
            
            obj.timeOfInterestStart     = obj.timeOfInterestStart + duration(0,30,0);
            obj.timeOfInterestEnd       = obj.timeOfInterestEnd - duration(0,30,0);
           
            obj     = readInternalSensors(obj);
            obj     = readAuxillarySensors(obj);
            obj     = assignSensorMountingData(obj);
            obj     = calibrateSensors(obj);
            
            obj     = readAnalyticalSamples(obj);
            
%             obj     = runAnalysis(obj);
        end
        
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
    end
    
	% methods in seperate files
    methods (Access = public)
       	obj	= runAnalysis(obj)
    end
    
    methods (Access = protected)
        obj = readInternalSensors(obj)
        obj = planarFitCoordinateSystem(obj)
    end 
end