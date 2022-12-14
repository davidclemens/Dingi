function output = evalToken(token)

    tokenType = token.Type;
    tokenText = token.Text;
    if strcmp(tokenType,'NAME')
        output = tokenText;
    elseif strcmp(tokenType,'NUMBER')
        output = str2double(tokenText);
    else
        error('Dingi:Units:Parser:parser:evalToken:UnknownTokenType',...
            'Unknown token type ''%s''.',tokenType)
    end
end
