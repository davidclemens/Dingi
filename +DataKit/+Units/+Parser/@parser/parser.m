classdef parser
    % PARSER  Parse text input
    % Parse text input of different types (e.g. maths expressions) using basic
    % lexical scanning and pipe it into multiple output formats (e.g. function
    % handles)
    %
    % PARSER Properties:
    %   IsMultiplicative - Determine if expression is multiplicative
    %   IsNumeric - Determine if expression has only numbers
    %   Text - Input text stream
    %   Tokens - Tokens extracted from Text
    %   Tree - Evaluation tree extracted form Tokens
    %   Type - Input text type
    %
    % PARSER Methods:
    %   parser - Construct text stream parser
    %   createEvalTreeNode - Recursively create evaluation tree from tokens
    %   graph - Plot parser as graph
    %   toChar - 
    %   tokenize - Basic lexical scanner for maths expressions
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties (SetAccess = 'protected')
        Text char % Input text stream
        Type char % Input text type
    end
    properties (Dependent)
        Tokens struct % Tokens extracted from Text
        Tree % Evaluation tree extracted form Tokens
        IsMultiplicative logical % Determine if expression has no sums that depend on names
        IsNumeric logical % Determine if expression has only numbers
    end
    properties (Constant, Access = private)
        ValidTypes = {'Expression'}
        OperatorMap containers.Map = containers.Map(...
            {'^','*','','/','+','-'}, {@power,@times,@times,@rdivide,@plus,@minus})
        UnaryOperatorMap containers.Map = containers.Map(...
            {'+','-'}, {@(x) x,@(x) -1.*x})
        OperatorPriorityMap containers.Map = containers.Map(...
            {'^','unary','*','','/','+','-'},[3,2,1,1,1,0,0])
    end
    
    % Constructor
    methods
        function obj = parser(C,type)
            % parser  Construct text stream parser
            %   PARSER tokenizes and parses a char input text stream.
            %
            %   Syntax
            %     obj = PARSER(C,type)
            %
            %   Description
            %     obj = PARSER(C,type)  Parse a char stream C of type type and return the
            %       result as a parser instance obj. See other methods like char or eval to
            %       generate parsed outputs.
            %
            %   Example(s)
            %     obj = PARSER('5 + 3','Expression')  returns a parser instance obj for the
            %       input '5 + 3' of type 'Expression'.
            %
            %
            %   Input Arguments
            %     C - Char stream
            %       char row vector
            %         Input char stream specified as a char row vector.
            %
            %     type - Input type
            %       'Expression' (default)
            %         Input type of the char stream C, specified as 'Expression' (default).
            %         The type determines the way the character stream is parsed:
            %           - 'Expression'	The char stream is interpreted as a mathematical
            %                           expression (e.g. '5 + 3' or '1.3 ^ (2 + 3)').
            %
            %
            %   Output Arguments
            %     obj - Parser
            %       DataKit.Units.Parser.parser
            %         Parser returned as a DataKit.Units.Parser.parser instance.
            %
            %
            %   Name-Value Pair Arguments
            %
            %
            %   See also DATAKIT.UNITS.PARSER.PARSER.TOCHAR,
            %   DATAKIT.UNITS.PARSER.PARSER.TOFUNCTION
            %
            %   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
            %
                        
            if nargin == 0
                return
            end
            
            narginchk(2,2)

            % Validate input
            validateattributes(C,{'char'},{'row'},mfilename,'C',1)
            type = validatestring(type,obj.ValidTypes,mfilename,'type',2);
            
            obj.Text    = C;
            obj.Type    = type;
        end
    end
    
    methods
        C = toChar(obj,varargin)
        h = graph(obj)
        tf = isMultiplicative(obj)
    end
    methods (Static)
        tkns = tokenize(stream)
        varargout = createEvalTreeNode(tokens,varargin)
    end
    
    % GET methods
    methods
        function tokens = get.Tokens(obj)
            
            tokens = DataKit.Units.Parser.parser.tokenize(obj.Text);
        end
        function tree = get.Tree(obj)
            
            tree = DataKit.Units.Parser.parser.createEvalTreeNode(obj.Tokens,...
                'OperatorPriority',     obj.OperatorPriorityMap);
        end
        function isMultiplicative = get.IsMultiplicative(obj)
            
            isMultiplicative = obj.Tree.isMultiplicative;
        end
        function isNumeric = get.IsNumeric(obj)
            
            isNumeric = obj.Tree.isNumeric;
        end
    end
end

