function C = char(obj)

    % Get current float format setting
    dblFmt = DataKit.quantity.getDisplayFloatFormats();

    % Reshape into column vectors
    d = reshape(double(obj),[],1);
    u = reshape(obj.StDev,[],1);

    % Align values and uncertainties on decimal seperator, respectively
    value       = num2dotalignedstr(d,dblFmt);
    uncertainty = num2dotalignedstr(u,dblFmt);

    % Join values and uncertainties with plus/minus sign
    cellStr = strcat(value,{[' ',char(177),' ']},uncertainty);

    % Return as a char array
    C = cat(1,cellStr{:});

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
