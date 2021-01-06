function disp(obj)
% disp  Displays metadata of a dataFlag instance
%   DISP displays metadata of a dataFlag instance. It overloads the
%   builtin disp(x) function.
%
%   Syntax
%     data = DISP(obj)
%
%   Description
%     data = DISP(obj) displays metadata of a dataFlag instance.
%
%   Example(s)
%     data = DISP(obj)
%
%
%   Input Arguments
%     obj - dataFlag
%       dataFlag
%         An instance of the dataFlag class.
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
%   Copyright 2021 David Clemens (dclemens@geomar.de)
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
    
    tabLength       = max([10,5 + ndigits(max(i)) + ndigits(max(j))]);
    
	fprintf('  %ux%u <a href="matlab:help(''DataKit.Metadata.dataFlag'')">data flag</a>\n\n',sz(1),sz(2))
    
    if N > 0
        for ii = 1:n
            flagIds = find(bitget(v(ii),1:52));
            flagCellstr = cellstr(DataKit.Metadata.dataFlag.id2validflag(flagIds));
            indexStr = sprintf('(%u, %u)',i(ii),j(ii));
            fprintf('%s%s%s\n',indexStr,repmat(' ',1,tabLength - numel(indexStr)),strjoin(flagCellstr,', '))
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
        fprintf('%sNo flag is set.\n\n',repmat(' ',1,tabLength))
    end
end