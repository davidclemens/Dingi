function disp(obj,varargin)
% disp  Displays metadata of a bitflag instance
%   DISP displays metadata of a bitflag instance. It overloads the
%   builtin disp(x) function.
%
%   Syntax
%     DISP(obj)
%     DISP(__,'builtin')
%     DISP(__,'bits')
%
%   Description
%     DISP(obj) displays metadata of a bitflag instance.
%     DISP(__,'builtin') runs the builtin disp method.
%     DISP(__,'bits') displays the underlying bitmask.
%
%   Example(s)
%     DISP(obj)
%
%
%   Input Arguments
%     obj - bitflag
%       DataKit.bitflag
%         An instance of the DataKit.bitflag class.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also BITFLAG
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%
    
    import DataKit.accumcell
    import DataKit.ndfind
    import DataKit.ndigits
    
    narginchk(1,2)
    if nargin == 1
        callBuiltin     = false;
        showAsBitmask   = false;
    elseif nargin == 2
        validOptions    = {'builtin','bitmask'};
        callBuiltin     = strcmp(validatestring(varargin{1},validOptions),'builtin');
        showAsBitmask   = strcmp(validatestring(varargin{1},validOptions),'bitmask');
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
	fprintf(['  %u',repmat('x%u',1,nDims - 1),' <a href="matlab:help(''DataKit.bitflag'')">bitflag</a>\n\n'],sz)
    
    if N > 0
        tabLength  	= max([minTab,3 + 2*(nDims - 1) + sum(ndigits(cellfun(@max,subs)))]);
        indexStr    = cellstr(num2str(subsref(cat(2,subs{:}),substruct('()',{1:n,':'})),['(',strjoin(repmat({'%u'},1,nDims),', '),')\n']));
        tabStr      = arrayfun(@(l) repmat(' ',1,l),tabLength - cellfun(@numel,indexStr),'un',0);
        
        if showAsBitmask
            headerNums  = fliplr(num2str((1:obj.StorageType)','%u')');
            maskStr     = cellstr(dec2bin(v(1:n),obj.StorageType));
            maskStr     = strrep(maskStr,'0','.');
            printStr    = strcat(indexStr,tabStr,maskStr);
            
            noFlag      = false;
            
            % Print header numbers
            for hl = 1:size(headerNums,1)
                if hl == 1
                    fprintf('(index)%s%s\n',repmat(' ',1,tabLength - 7),headerNums(hl,:));
                else
                    fprintf('%s%s\n',repmat(' ',1,tabLength),headerNums(hl,:));
                end
            end
        else
            flagNames   = obj.EnumerationMembers;
            [ind,bit]   = find(bitget(repmat(v(1:n),1,obj.StorageType),repmat(1:obj.StorageType,n,1)));
            
            % Make sure these are column vectors, as this changes with only input to
            % find().
            ind         = reshape(ind,[],1);
            bit         = reshape(bit,[],1);
            
            noFlag      = bit > numel(flagNames);
            
            flagStr             = repmat({'<NoFlagName>'},numel(bit),1);
            flagStr(~noFlag) 	= flagNames(bit(~noFlag));
            
            flagStr             = accumcell(ind,flagStr,[n,1],@(x) strjoin(x,', '));
            printStr    = strcat(indexStr,tabStr,flagStr);            
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
        
        if any(noFlag)
            fprintf('%sTo see the bitmask behind ''<NoFlagName>'' entries, run disp(obj,''bitmask'').\n\n',repmat(' ',1,minTab))
        end
    else
        fprintf('%sNo flag is set.\n\n',repmat(' ',1,minTab))
    end
end