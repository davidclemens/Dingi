classdef dataFlag < DataKit.Metadata.sparseBitmask
       
    methods
        function obj = dataFlag(varargin)
            
            
            %   Syntax
            %     obj = dataFlag(A)
            %     obj = dataFlag(m,n)
            %     obj = dataFlag(i,j,flagId)
            %     obj = dataFlag(i,j,flagId,m,n)
            
            obj     = obj@DataKit.Metadata.sparseBitmask(varargin{:});
            
            % validate input ids
            switch nargin
                case 0
                    % Return empty dataFlag
                    return
                case 1
                    % Convert input array to dataFlag array
                    bitmasks	= varargin{1}(:);
                    isNotZero  	= bitmasks ~= 0;
                    bitmasks    = full(bitmasks(isNotZero));
                    n           = sum(isNotZero);
                    bitmask   	= zeros(n,52);
                    for ii = 1:n
                        bitmask(ii,:) = bitget(bitmasks(ii),1:52);
                    end
                    [~,bitPosition]	= find(bitmask);
                    flagId          = bitPosition;
                case 2
                    % Initialize dataFlag array of size m x n with all flagId set to 0
                    flagId  = 0;
                case 3
                    % Initialize dataFlag array of size max(i(:)) x max(j(:)) and set dataFlag
                    % at index (i,j) to flagId
                    flagId	= varargin{3}(:);
                case 5
                    % Initialize dataFlag array of size m x n and set dataFlag at index (i,j)
                    % to flagId
                    flagId	= varargin{3}(:);
                otherwise
                    error('Dingi:DataKit:Metadata:dataFlag:invalidNumberOfInputs',...
                        'Invalid number of inputs.')
            end
            isValid = DataKit.Metadata.validators.validFlag.validate('Id',flagId);
            if any(~isValid)
                error('Dingi:DataKit:Metadata:dataFlag:dataFlag:invalidFlagId',...
                    '%u is an invalid flag id.',flagId(find(~isValid,1)))
            end
        end
    end
    
    methods
        tf = isFlag(obj,flag)
    end
    
    methods (Static)
        obj = id2validflag(id)
    end
    
    % Overloaded methods
    methods
        varargout = subsref(obj,s)
        obj = cat(dim,varargin)
        obj = horzcat(varargin)
        obj = vertcat(varargin)
        tf = eq(obj1,obj2)
    end
end