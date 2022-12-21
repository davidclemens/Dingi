classdef dimension < double
    properties (SetAccess = immutable)
        Name % Name of dimension
        Value = 1 % value of dimension in terms of other dimensions
        Dimensions = {} % dimensions
        Degrees % power of each dimension
    end
    properties (Dependent)
        IsBaseDimension logical
    end
    
    % Constructor
    methods
        function obj = dimension(name,value)
            
            import DataKit.Units.Parser.parser
            
            narginchk(1,2)
            
            % Set default value(s)
            defaultValue	= 1;
            if nargin == 1
                value  = defaultValue;
            end
           
            % Input validation
            validateattributes(name,{'char'},{'row'},mfilename,'name',1)
            validateattributes(value,{'numeric'},{'scalar'},mfilename,'value',2)
            if ~isa(value,'DataKit.Units.dimension')
                assert(value == 1,...
                    'Dingi:DataKit:Units:dimension:dimension:InvalidValue',...
                    'Expected input number 2, value, to be a DataKit.Units.dimension or set to 1 for base dimensions.')
            end
            
            % Processing
            if isa(value,'DataKit.Units.dimension')
                dimensions  = value.Dimensions;
                exponents	= value.Degrees;
            else
                if value == 1
                    p = parser(name,'Expression');
                else
                    p = parser(value.Name,'Expression');
                end
                [dimensions,exponents] = p.Tree.getDimensionality;
            end
            
            % Create object and populate properties    
            obj             = obj@double(value);
            obj.Name        = name;
            obj.Value   	= value;
            obj.Dimensions  = dimensions;
            obj.Degrees     = exponents;
            
            % Simplify name
            obj.Name        = simplifyName(obj);
        end
    end
    
    methods
        name = simplifyName(obj)
    end
    
    % Overloaded methods
    methods
        disp(obj,varargin)
        C = char(obj)
        B = subsref(obj,S)
        obj = subsasgn(obj,S,B)
        C = times(obj,B)
        C = rdivide(obj,B)
        C = power(obj,B)
        tf = eq(obj,B)
    end
    
    % GET methods
    methods
        function isBaseDimension = get.IsBaseDimension(obj)
            isBaseDimension = ~isa(obj.Value,'DataKit.Units.dimension');
        end
    end
    
    methods
        function C = mtimes(obj,B)
            C = times(obj,B);
        end
        function C = ldivide(obj,B)
            C = rdivide(B,obj);
        end
        function C = mrdivide(obj,B)
            C = rdivide(obj,B);
        end
        function C = mldivide(obj,B)
            C = rdivide(B,obj);
        end
        function C = mpower(obj,B)
            C = power(obj,B);
        end
        function tf = ne(obj,B)
            tf = ~eq(obj,B);
        end
        function C = vertcat(obj,varargin)
            C = cat(1,obj,varargin{:});
        end
        function C = horzcat(obj,varargin)
            C = cat(2,obj,varargin{:});
        end
        function tf = lt(obj,B) %#ok<INUSD>
            tf = compare(obj);
        end
        function tf = gt(obj,B) %#ok<INUSD>
            tf = compare(obj);
        end
        function tf = le(obj,B) %#ok<INUSD>
            tf = compare(obj);
        end
        function tf = ge(obj,B) %#ok<INUSD>
            tf = compare(obj);
        end
        function tf = and(obj,B) %#ok<INUSD>
            tf = logicalCombine(obj);
        end
        function tf = or(obj,B) %#ok<INUSD>
            tf = logicalCombine(obj);
        end
        function tf = not(obj)
            tf = logicalCombine(obj);
        end
        function C = plus(obj,B) %#ok<STOUT,INUSD>
            error('Dingi:DataKit:Units:dimension:plus:InvalidOperation',...
                'Addition is not a valid operation for dimensions.')
        end
        function C = minus(obj,B) %#ok<STOUT,INUSD>
            error('Dingi:DataKit:Units:dimension:minus:InvalidOperation',...
                'Subtraction is not a valid operation for dimensions.')
        end
        function C = uplus(obj) %#ok<MANU,STOUT>
            error('Dingi:DataKit:Units:dimension:uplus:InvalidOperation',...
                'Unary addition is not a valid operation for dimensions.')
        end
        function C = uminus(obj) %#ok<MANU,STOUT>
            error('Dingi:DataKit:Units:dimension:uminus:InvalidOperation',...
                'Unary subtraction is not a valid operation for dimensions.')
        end
        function C = cat(dim,obj,varargin) %#ok<STOUT,INUSD>
            error('Dingi:DataKit:Units:dimension:cat:InvalidOperation',...
                'Concatenation is not a valid operation for dimensions as they are always scalar.')
        end
        function C = colon(obj,varargin) %#ok<STOUT,INUSD>
            error('Dingi:DataKit:Units:dimension:colon:InvalidOperation',...
                'The colon operator is not a valid operation for dimensions as they are always scalar.')
        end
        function C = ctranspose(obj) %#ok<MANU,STOUT>
            error('Dingi:DataKit:Units:dimension:ctranspose:InvalidOperation',...
                'The complex conjugate transpose operation is not a valid operation for dimensions as they are always scalar.')
        end
        function C = transpose(obj) %#ok<MANU,STOUT>
            error('Dingi:DataKit:Units:dimension:transpose:InvalidOperation',...
                'The matrix transpose operation is not a valid operation for dimensions as they are always scalar.')
        end
        function compare(obj) %#ok<MANU>
            error('Dingi:DataKit:Units:dimension:compare:InvalidOperation',...
                'Some comparison operations (<, >, <=, >=) are''t valid operations for dimensions.')
        end
        function logicalCombine(obj) %#ok<MANU>
            error('Dingi:DataKit:Units:dimension:logicalCombine:InvalidOperation',...
                'Logical operators (&, | and ~) are''t valid operations for dimensions.')
        end
    end
end
