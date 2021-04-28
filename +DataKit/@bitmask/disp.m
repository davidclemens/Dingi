function disp(obj,varargin)
% disp  Displays metadata of a bitmask instance
%   DISP displays metadata of a bitmask instance. It overloads the
%   builtin disp(x) function.
%
%   Syntax
%     DISP(obj)
%     DISP(__,'builtin')
%
%   Description
%     DISP(obj) displays metadata of a bitmask instance.
%     DISP(__,'builtin') runs the builtin disp method.
%
%   Example(s)
%     DISP(obj)
%
%
%   Input Arguments
%     obj - bitmask
%       DataKit.bitmask
%         An instance of the DataKit.bitmask class.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also BITMASK
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%
    
    import DataKit.accumcell
    import DataKit.ndfind
    import DataKit.ndigits
    
    narginchk(1,2)
    if nargin == 1
        callBuiltin     = false;
    elseif nargin == 2
        validOptions    = {'builtin','bitmask'};
        callBuiltin     = strcmp(validatestring(varargin{1},validOptions),'builtin');
    end

    if callBuiltin
        builtin('disp',obj);
        return
    end
    
    sz              = obj.Size;
    nDims           = ndims(obj.Bits);
    
    % Find elements with set flags
    subs            = cell(1,nDims);
    [v,subs{:}]     = ndfind(obj.Bits);
    N               = numel(v);
    
    % Process a limit to not output all elements
    Limit           = 99;
    LimitIsReached  = N > Limit;
    if LimitIsReached
        n = Limit;
    else
        n = N;
    end
    minTab  = 10;
    
    % Print header
	fprintf(['  %u',repmat('x%u',1,nDims - 1),' <a href="matlab:help(''DataKit.bitmask'')">bitmask</a>\n\n'],sz)
    
    if N > 0
        tabLength  	= max([minTab,3 + 2*(nDims - 1) + sum(ndigits(cellfun(@max,subs)))]);
        headerNums  = fliplr(num2str((1:obj.StorageType)','%u')');
        indexStr    = cellstr(num2str(subsref(cat(2,subs{:}),substruct('()',{1:n,':'})),['(',strjoin(repmat({'%u'},1,nDims),', '),')\n']));
        tabStr      = arrayfun(@(l) repmat(' ',1,l),tabLength - cellfun(@numel,indexStr),'un',0);
        
        maskStr     = cellstr(dec2bin(v(1:n),obj.StorageType));
        maskStr     = strrep(maskStr,'0','.');
        printStr    = strcat(indexStr,tabStr,maskStr);
        
        % Print header numbers
        for hl = 1:size(headerNums,1)
            if hl == 1
                fprintf('(index)%s%s\n',repmat(' ',1,tabLength - 7),headerNums(hl,:));
            else
                fprintf('%s%s\n',repmat(' ',1,tabLength),headerNums(hl,:));
            end
        end
        
        % Print contents
        fprintf('%s\n',printStr{:})
        
        if LimitIsReached
            fprintf('%s:\n',repmat(' ',1,minTab))
            fprintf('%s:\n',repmat(' ',1,minTab))
            fprintf('%sOnly showing %u of %u elements.\n\n',repmat(' ',1,minTab),n,N)
        else
            fprintf('\n')
            fprintf('%sShowing %u of %u elements.\n\n',repmat(' ',1,minTab),n,N)
        end
    else
        fprintf('%sNo bit is set.\n\n',repmat(' ',1,minTab))
    end
end