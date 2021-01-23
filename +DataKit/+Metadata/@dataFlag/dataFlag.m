classdef dataFlag < DataKit.Metadata.sparseBitmask
       
    methods
        function obj = dataFlag(varargin)
            
            obj     = obj@DataKit.Metadata.sparseBitmask(varargin{:});
            
            % validate input ids
            switch nargin
                case 0
                    return
                case 1
                    bitmasks	= varargin{1}(:);
                    isNotZero  	= bitmasks ~= 0;
                    bitmasks    = full(bitmasks(isNotZero));
                    n           = sum(isNotZero);
                    bitmask   	= zeros(n,52);
                    for ii = 1:n
                        bitmask(ii,:) = bitget(bitmasks(ii),1:52);
                    end
                    [~,flagId]  = find(bitmask);
                case 2
                    flagId  = 0;
                case 3
                    flagId	= varargin{3}(:);
                case 5
                    flagId	= varargin{3}(:);
                otherwise
                    error('Dingi:DataKit:Metadata:dataFlag:invalidNumberOfInputs',...
                        'Invalid number of inputs.')
            end
            isValid = DataKit.Metadata.dataFlag.validateId(flagId);
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
    	[bool,info] = validateId(id)
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