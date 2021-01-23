function disp(obj)
% disp  Displays metadata of a sparseBitmask instance
%   DISP displays metadata of a sparseBitmask instance. It overloads the
%   builtin disp(x) function.
%
%   Syntax
%     data = DISP(obj)
%
%   Description
%     data = DISP(obj) displays metadata of a sparseBitmask instance.
%
%   Example(s)
%     data = DISP(obj)
%
%
%   Input Arguments
%     obj - sparse bitmask
%       sparseBitmask
%         An instance of the sparseBitmask class.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also SPARSEBITMASK
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%
    
    import DataKit.ndigits
    
    [i,j,v]         = find(obj.Bitmask);
    N               = numel(i);
    sz              = size(obj.Bitmask);
    Limit           = 99;
    LimitIsReached  = N > Limit;
    if LimitIsReached
        n = Limit;
    else
        n = N;
    end
    
    headerNumbers   = fliplr(num2str((1:52)','%u')');
    tabLength       = max([10,5 + ndigits(max(i)) + ndigits(max(j))]);
    
	fprintf('  %ux%u <a href="matlab:help(''DataKit.Metadata.sparseBitmask'')">sparse bitmask</a>\n\n',sz(1),sz(2))
    
    if N > 0
        fprintf('(index)%s%s\n',repmat(' ',1,tabLength - 7),headerNumbers(1,:));
        fprintf('%s%s\n\n',repmat(' ',1,tabLength),headerNumbers(2,:));
        for ii = 1:n
            maskStr     = dec2bin(v(ii),52);
            maskStr     = strrep(maskStr,'0','.');
            indexStr    = sprintf('(%u, %u)',i(ii),j(ii));
            fprintf('%s%s%s\n',indexStr,repmat(' ',1,tabLength - numel(indexStr)),maskStr)
        end
        if LimitIsReached
            fprintf('%s:\n',repmat(' ',1,tabLength))
            fprintf('%s:\n',repmat(' ',1,tabLength))
            fprintf('%sOnly showing %u of %u elements.\n\n',repmat(' ',1,tabLength),n,N)
        else
            fprintf('\n')
            fprintf('%sShowing %u of %u elements.\n\n',repmat(' ',1,tabLength),n,N)
        end
    else
        fprintf('%sNo bit is set.\n\n',repmat(' ',1,tabLength))        
    end
end