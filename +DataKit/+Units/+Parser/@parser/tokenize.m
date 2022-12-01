function tkns = tokenize(stream)
% tokenize  Basic lexical scanner for maths expressions
%   TOKENIZE performs a basic lexical scan of maths expressions. The expression
%   is provided as a char row vector. TOKENIZE returns the found tokens as a
%   struct vector containing metadata about the tokens.
%
%   Syntax
%     tkns = TOKENIZE(stream)
%
%   Description
%     tkns = TOKENIZE(stream)  performs a lexical scan of the maths expression
%       and char row vector stream and returns the found tokens as struct tkns.
%
%   Example(s)
%     tkns = TOKENIZE('3 + 5')  returns 3x1 struct tkns with fields Text, Type &
%       ExactType.
%
%
%   Input Arguments
%     stream - Maths expression
%       char row vector
%         The maths expression provided as a char row vector.
%
%
%   Output Arguments
%     tkns - Token struct
%       struct
%         The found tokens returned as a struct with the fields Text, Type &
%         ExactType. The struct is of size nx1, where n is the number of tokens
%         found in stream.
%         The field Text stores the literal portion of the stream that the
%         respective token refers to.
%         The field Type stores the token type and can be one of the following:
%         OP, NAME or NUMBER.
%         The field Exacttype stores the exact token type and can be one of the
%         following: OP, DELIM, STR, INT or FLOAT.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.UNITS.PARSER.PARSER
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    % Definitions inspired by python literals. See https://docs.python.org/3/reference/lexical_analysis.html
    
    % Chars
    alphaChar       = '[A-Za-z]';
    alphaNumChar    = '\w';
    symbolChar      = '[_\[\]]';
    charString      = [alphaChar,'[',alphaNumChar,symbolChar,']*'];
    dimString       = ['\[',charString,'\]']; % Also add dimension string
    
    % Integers
    digit           = '\d';
    nonZeroDigit    = ['[','1':'9',']'];
    decInteger      = ['(',nonZeroDigit,digit,'*|0)'];
    integerNumber   = decInteger; % This could also be expandet to include binary, octal or hex integers
    
    % Floats
    digitPart       = [digit,'+'];
    fraction        = ['\.',digitPart];
    exponent        = ['[eE][\+\-]?',digitPart];
    pointFloat      = ['((',digitPart,')*',fraction,'|',digitPart,'\.)'];
    exponentFloat   = ['(',digitPart,'|',pointFloat,')',exponent];
    floatNumber     = ['(',exponentFloat,'|',pointFloat,')'];
    
    % Operators
    % For '+': look behind to check that the '+' is not part of an exponent, e.g. '3e+5'
    % For '-': look behind to check that the '-' is not part of an exponent, e.g. '3e-5'
    operators       = {'\^','\*','\/','(?<![eE])\+','(?<![eE])\-'};
    operatorTypes   = {'POWER','TIMES','DIVIDE','PLUS','MINUS'};
    
    % Delimiters
    delimiters      = {'\(','\)'};
    delimiterTypes  = {'PAROPEN','PARCLOSE'};
    
    % Split the stream into tokens
    stream = splitStream(stream);
    
    % Get the token types
    typeOperator        = ~cellfun(@isempty,regexp(stream,['^(',strjoin(operators,'|'),')$']));
    typeDelimiter       = ~cellfun(@isempty,regexp(stream,['^(',strjoin(delimiters,'|'),')$']));
    typeCharString      = ~cellfun(@isempty,regexp(stream,['^',charString,'$']));
    typeDimString       =  ~cellfun(@isempty,regexp(stream,['^',dimString,'$']));
    typeIntegerNumber	= ~cellfun(@isempty,regexp(stream,['^',integerNumber,'$']));
    typeFloatNumber     = ~cellfun(@isempty,regexp(stream,['^',floatNumber,'$']));
    
    % Error checking
    types = cat(2,typeOperator,typeDelimiter,typeCharString,typeDimString,typeIntegerNumber,typeFloatNumber);
    assert(all(sum(types,2) == 1),...
        'Dingi:DataKit:Units:parser:parser:tokenize:Error',...
        'An error occurred during tokenization.')
    
    % Create tokens struct
    [typesInd,~]    = find(types');
    typeNames       = {'OP';'OP';'NAME';'NAME';'NUMBER';'NUMBER'};
    exactTypeNames 	= {'OP';'DELIM';'VAR';'DIM';'INT';'FLOAT'};
    typesList       = typeNames(typesInd);
    exactTypesList  = exactTypeNames(typesInd);
    
    exactTypesList  = assignExactOpType(exactTypesList);
    exactTypesList  = assignExactDelimType(exactTypesList);

    tkns            = struct(...
        'Text',         stream,...
        'Type',         typesList,...
        'ExactType',    exactTypesList);
    

    function S = splitStream(stream)
        % splitStream  Split char stream into tokens
        %   SPLITSTREAM splits char row vector stream at whitspace characters, operators
        %   or delimiters and returns a cellstr of splits.
        
        % Split at whitespace
        splits = regexp(stream,'\s','split');

        % Split at operators or delimiters
        [splits,match] = regexp(splits,['(',strjoin(cat(2,operators,delimiters),'|'),')'],'split','match');

        % Assemble stream without seperators
        S = {};
        for ii = 1:numel(splits)
            for mm = 1:numel(match{ii})
                S = cat(1,S,splits{ii}(mm),match{ii}(mm));
            end
            S = cat(1,S,splits{ii}(end));
            
            % Remove empty entries
            S(cellfun(@isempty,S)) = [];
        end
    end
    function lst = assignExactOpType(lst)
        isOp                = strcmp(lst,'OP');
        tmp                 = cellfun(@(e) ~cellfun(@isempty,regexp(stream(isOp),e)),operators,'un',0);
        exactTypes          = cat(2,tmp{:});
        [exactTypesInd,~]	= find(exactTypes');
        lst(isOp)           = operatorTypes(exactTypesInd);
    end
    function lst = assignExactDelimType(lst)
        isDelim             = strcmp(lst,'DELIM');
        tmp                 = cellfun(@(e) ~cellfun(@isempty,regexp(stream(isDelim),e)),delimiters,'un',0);
        exactTypes          = cat(2,tmp{:});
        [exactTypesInd,~]	= find(exactTypes');
        lst(isDelim)        = delimiterTypes(exactTypesInd);
    end
end

