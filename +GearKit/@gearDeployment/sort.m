function varargout = sort(obj,varargin)
% sort  Sorts gearDeployment array elements
%   SORT sorts gearDeployment array elements according to their deployment
%   time.

    A = cat(1,obj.timeDeployment);
    
    [~,sortInd] = sort(A,varargin{:});
    
    varargout{1} = obj(sortInd);
    varargout{2} = sortInd;
end

