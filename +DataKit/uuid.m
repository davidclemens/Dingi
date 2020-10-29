function uuid = uuid(varargin)

    if nargin == 0
        s(1) = 1;
        s(2) = 1;
    elseif nargin == 1
        s(1) = varargin{1};
        s(2) = s(1);
    elseif nargin == 2
        s(1) = varargin{1};
        s(2) = varargin{2};
    else
        s = cat(2,varargin{:});
    end
    
    % base function
    uuidFunc    = @() char(java.util.UUID.randomUUID);
    
    n           = prod(s);
    
    if n > 1e5
        error('too many requested UUIDs')
    end
    
   	uuid    = repmat(' ',n,36);
    for ii = 1:n
        uuid(ii,:) = uuidFunc();
    end
end