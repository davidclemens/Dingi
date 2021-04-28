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
    
    [i,j,v]         = find(obj.Bits);
    i               = reshape(i,[],1);
    j               = reshape(j,[],1);
    v               = reshape(v,[],1);
    sz              = obj.Size;
    nDims           = numel(sz);
    if nDims > 2
        % If obj.Bits is a multidimensional array with N > 2, then j is a linear
        % index over the N-1 trailing dimensions of obj.Bits. This preserves the
        % relation obj.Bits(i(ii),j(ii)) == v(ii).
        subs            = cell(1,nDims);
        subs{1}         = i;
        [subs{2:end}]   = ind2sub(sz(2:end),j);
    else
        subs = {i,j};
    end
    N               = numel(i);
    
    Limit           = 99;
    LimitIsReached  = N > Limit;
    if LimitIsReached
        n = Limit;
    else
        n = N;
    end
    minTab  = 10;
    
	fprintf(['  %u',repmat('x%u',1,nDims - 1),' <a href="matlab:help(''DataKit.bitflag'')">bitflag</a>\n\n'],sz)
    
    if N > 0
        tabLength  	= max([minTab,3 + 2*(nDims - 1) + sum(ndigits(cellfun(@max,subs)))]);
        indexStr    = cellstr(num2str(subsref(cat(2,subs{:}),substruct('()',{1:n,':'})),['(',strjoin(repmat({'%u'},1,nDims),', '),')\n']));
        tabStr      = arrayfun(@(l) repmat(' ',1,l),tabLength - cellfun(@numel,indexStr),'un',0);
        
        if showAsBitmask
            maskStr     = cellstr(dec2bin(v(1:n),obj.StorageType));
            maskStr     = strrep(maskStr,'0','.');
            printStr    = strcat(indexStr,tabStr,maskStr);
            
            noFlag      = false;
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