function C = char(obj)
% char  Convert to character array
%   CHAR converts quantity array obj into a character array. The quantity array
%   is vectorized such that C(i,:) holds the character representation of obj(i).
%   The character representation is of the form value ± uncertainty flag.
%
%   Syntax
%     C = CHAR(obj)
%
%   Description
%     C = CHAR(obj)  Convert the quantity array obj to its character 
%     representation C.
%
%   Example(s)
%     C = CHAR(DataKit.quantity(2,0.5,3))  returns C = '2 ± 0.5 2⚑'
%
%
%   Input Arguments
%     obj - Input quantity
%       DataKit.quantity array
%         Input quantity specified as a DataKit.quantity array.
%
%
%   Output Arguments
%     C - Output array
%       char array
%         Output array, returned as a character array. It has as many rows as
%         obj has elements.
%         The character representation consists of the value ± its uncertainty
%         and the number of flags that are set to high, indicated by the count
%         and a flag symbol.
%          
%         Tip: Using reshape(num2cell(C,2),sz), where sz = size(obj), returns
%         the character representation as cellstr with the shape of the original
%         quantity array.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DataKit.quantity, DataKit.quantity.disp
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Get current float format setting
    dblFmt = DataKit.quantity.getDisplayFloatFormats();

    % Reshape into column vectors
    d = reshape(double(obj),[],1);
    u = reshape(obj.Sigma,[],1);
    f = reshape(obj.Flag,[],1);

    % Align values and uncertainties on decimal seperator, respectively
    value       = num2dotalignedstr(d,dblFmt);
    uncertainty = num2dotalignedstr(u,dblFmt);
    flag        = flag2indicatorstr(f);

    % Join values and uncertainties with plus/minus sign
    cellStr = strcat(value,{[' ',char(177),' ']},uncertainty,flag);

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
    function S = flag2indicatorstr(F)
        
        flagChar = char(hex2dec('2691'));
        
        nF = arrayfun(@(b) F.isBit(b),1:64,'un',0);
        nF = sum(cat(3,nF{:}),3);
        
        S = strcat({' '},cellstr(num2str(nF,'%u')),{flagChar});
        S = regexprep(S,['^(\s+)0',flagChar,'$'],'$1  ');
    end
end
