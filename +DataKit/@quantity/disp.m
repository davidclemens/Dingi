function disp(obj,varargin)

    % Input checks
    narginchk(1,2)

    % Allow calling of the builtin method
    if nargin == 1
        callBuiltin     = false;
    elseif nargin == 2
        validOptions    = {'builtin','quantity'};
        callBuiltin     = strcmp(validatestring(varargin{1},validOptions),'builtin');
    end
    if callBuiltin
        builtin('disp',obj);
        return
    end

    % Get info
    sz              = size(obj);
    nDims           = ndims(obj);
    n               = numel(obj);

    % Process a limit to not output all elements
    limits          = ones(1,nDims);
    limits(1:2)    	= [99,5]; % [rows,cols]
    limitIsReached	= sz > limits;
    szDisp          = min(cat(1,limits,sz),[],1);

    % Definitions for printing
    minTabLength    = 5;
    minTab          = repmat(' ',1,minTabLength);
    colTabLength    = 5;
    colTab          = repmat(' ',1,colTabLength);

    % Print header
    fprintf(['  %u',repmat('x%u',1,nDims - 1),' <a href="matlab:help(''DataKit.quantity'')">quantity</a>\n\n'],sz)

    if n > 0
        % If non-empty
        if nDims <= 2
            dblFmt = DataKit.quantity.getDisplayFloatFormats();
            d = double(obj);
            d = d(1:szDisp(1),1:szDisp(2));
            u = obj.StDev;
            u = full(u(1:szDisp(1),1:szDisp(2)));
            f = obj.Flag;
            f = f(1:szDisp(1),1:szDisp(2));
            nF = arrayfun(@(b) f.isBit(b),1:64,'un',0);
            nF = sum(cat(3,nF{:}),3);
            
            colStr  = cell(szDisp);
            for col = 1:szDisp(2)
                value = num2dotalignedstr(d(:,col),dblFmt);
                uncertainty = num2dotalignedstr(u(:,col),dblFmt);
                flag = num2dotalignedstr(nF(:,col),'%u');
                %char(hex2dec('2691'))
                hasFlag     = nF(:,col) > 0;
                flagStr     = repmat({''},size(flag,1),1);
                flagStr(hasFlag) = strcat({' '},flag(hasFlag),{char(hex2dec('2691'))});
                colStr(:,col) = strcat(value,{[' ',char(177),' ']},uncertainty,flagStr);
            end

            printStr = colStr';

            if limitIsReached(2)
                % Print contents
                lastLineStr = printStr(:,end);
                printStr    = printStr(:,1:end - 1);
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),'\n'],printStr{:})
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),' .. .. Only showing %u of %u columns.\n'],lastLineStr{:},szDisp(2),sz(2))
            else
                % Print contents
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),'\n'],printStr{:})
            end

            if limitIsReached(1)
                fprintf('%s:\n',minTab)
                fprintf('%s:\n',minTab)
                fprintf('%sOnly showing the first %u of %u rows.\n\n',minTab,szDisp(1),sz(1))
            end
        else
            % Higher dimensions
            fprintf('%s[]\n\n',minTab)
        end
    else
        % If quantity is empty
        fprintf('%s[]\n\n',minTab)
    end
    function S = num2dotalignedstr(A,fmt)

        dotPosition = @(C) cellfun(@(c) numel(c{1}),cellfun(@(s) split(s,{'.','e','E'}),C,'un',0),'un',1) + 1;
        padding = @(l) arrayfun(@(l) repmat(' ',1,l),l,'un',0);

        str           	= splitlines(sprintf([fmt,'\n'],A));
        str            	= str(1:end - 1);
        strLength     	= cellfun(@numel,str);
        strDotPosition	= dotPosition(str);

        paddingLeft     = max(strDotPosition) - strDotPosition;
        paddingRight    = max(strLength - strDotPosition) - (strLength - strDotPosition);

        S = strcat(padding(paddingLeft),str,padding(paddingRight));
    end
end
