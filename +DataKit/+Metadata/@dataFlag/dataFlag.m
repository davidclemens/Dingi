classdef dataFlag < DataKit.Metadata.sparseBitmask
       
    methods
        function obj = dataFlag(varargin)
            
            obj     = obj@DataKit.Metadata.sparseBitmask(varargin{:});
            
            % validate input ids
            switch nargin
                case 0
                    return
                case 1
                    n       = numel(varargin{1}(:));
                    flagId  = zeros(n*52,1);
                    for ii = 1:n
                        s = (ii - 1)*52 + 1;
                        e = ii*52;
                        flagId(s:e) = bitget(varargin{1}(ii),1:52);
                    end
                case 2
                    flagId  = 0;
                case 3
                    flagId	= varargin{3}(:);
                case 5
                    flagId	= varargin{3}(:);
                otherwise
                    error('DataKit:Metadata:dataFlag:invalidNumberOfInputs',...
                        'Invalid number of inputs.')
            end
            isValid = DataKit.Metadata.dataFlag.validateId(flagId);
            if any(~isValid)
                error('DataKit:Metadata:dataFlag:dataFlag:invalidFlagId',...
                    '%u is an invalid flag id.',flagId(find(~isValid,1)))
            end
        end
    end
    
    methods (Static)
    	[bool,info] = validateId(id)
        obj = id2validflag(id)
    end
end