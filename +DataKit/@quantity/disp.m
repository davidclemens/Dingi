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
    limits(1:2)    	= [25,4]; % [rows,cols]
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
            % Render quantity as cellstr
            objDisp	= subsref(obj,substruct('()',{1:szDisp(1),1:szDisp(2)}));
            colStr 	= reshape(num2cell(char(objDisp),2),szDisp);

            % Output additional data
            printStr = colStr';
            if limitIsReached(2)
                % Print contents
                lastLineStr = printStr(:,end);
                printStr    = printStr(:,1:end - 1);
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),'\n'],printStr{:})
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),' ... Showing %u of %u columns.\n'],lastLineStr{:},szDisp(2),sz(2))
            else
                % Print contents
                fprintf([minTab,'%s',repmat([colTab,'%s'],1,szDisp(2) - 1),'\n'],printStr{:})
            end

            if limitIsReached(1)
                fprintf('%s.\n',minTab)
                fprintf('%s:\n',minTab)
                fprintf('%sShowing the first %u of %u rows.\n\n',minTab,szDisp(1),sz(1))
            end
        else
            % Higher dimensions
            % TODO: Implement display of all 2D pages
            fprintf('%s[]\n\n',minTab)
        end
    else
        % If quantity is empty
        fprintf('%s[]\n\n',minTab)
    end
end
