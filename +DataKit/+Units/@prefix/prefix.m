classdef prefix < double
    properties (SetAccess = immutable)
        Name char % Prefix name
        Symbol char = '' % Prefix symbol
        Aliases cell = {} % Prefix alias(es)
    end
    
    % Constructor
    methods
        function obj = prefix(name,value,symbol,aliases)
        % prefix  Create unit prefix
        %   PREFIX create a unit prefix instance.
        %
        %   Syntax
        %     obj = PREFIX(name,value)
        %     obj = PREFIX(name,value,symbol)
        %     obj = PREFIX(name,value,symbol,aliases)
        %
        %   Description
        %     obj = PREFIX(name,value)  Create a prefix object obj with name name and
        %       multiplicative value value.
        %     obj = PREFIX(name,value,symbol)  Additionally, provide a prefix symbol
        %       symbol.
        %     obj = PREFIX(name,value,symbol,aliases)  Additionally, provide prefix
        %       aliases.
        %
        %   Example(s)
        %     obj = PREFIX('kilo',1e3,'k')
        %     obj = PREFIX('micro',1e-6,'µ',{'mu','u'})
        %
        %
        %   Input Arguments
        %     name - Prefix name
        %       char row vector
        %         The prefix name, specified as a char row vector.
        %
        %     value - Prefix value
        %       numeric scalar
        %         The prefix multiplicative value, specified as a numeric scalar.
        %
        %     symbol - Prefix symbol
        %       char row vector | empty char
        %         The optional prefix symbol, specified as a char row vector. Defaults
        %         to an empty char, if no symbol is specified.
        %
        %     aliases - Prefix alias(es)
        %       cellstr | empty cell
        %         The optional prefix alias(es), specified as a cellstr. Defaults to an
        %         empty cell, if no alias is provided.
        %
        %
        %   Output Arguments
        %     obj - Prefix object
        %       DataKit.Units.prefix scalar
        %         The output prefix object, returned as a scalar DataKit.Units.prefix
        %         instance array.
        %
        %
        %   Name-Value Pair Arguments
        %
        %
        %   See also DATAKIT.UNITS.DIMENSION, DATAKIT.UNITS.UNIT,
        %   DATAKIT.UNITS.UNITCATALOG
        %
        %   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
        %
        
            narginchk(2,4)
            
            % Set default value(s)
            defaultSymbol   = '';
            defaultAlias    = {};
            if nargin == 2
                symbol  = defaultSymbol;
                aliases	= defaultAlias;
            elseif nargin == 3
                aliases	= defaultAlias;
            end
            
            % Input validation
            validateattributes(name,{'char'},{'row'},mfilename,'name',1)
            validateattributes(value,{'numeric'},{'scalar','finite','real','positive'},mfilename,'value',2)
            validateattributes(symbol,{'char'},{},mfilename,'symbol',3)
            if ~isempty(symbol)
                validateattributes(symbol,{'char'},{'row'},mfilename,'symbol',3)
            end
            validateattributes(aliases,{'cell'},{},mfilename,'aliases',4)
            if ~isempty(aliases)
                assert(iscellstr(aliases),'Dingi:DataKit:Units:prefix:prefix:NonCellstrAlias',...
                	'Expected input number 4, aliases, to be one of these types:\n\n\tempty cell, cellstr\n\nInstead its type was %s',class(aliases))
            end
            
            % Create object and populate properties
            obj         = obj@double(value);
            obj.Name    = name;
            obj.Symbol  = symbol;
            obj.Aliases	= aliases;
        end
    end
    
    % Overloaded
    methods
        B = subsref(obj,S)
        obj = subsasgn(obj,S,B)

        function C = times(obj,A)
            validateattributes(A,{'Quantities.unit'},{'scalar'},'times','u',2)
            C = Quantities.unit([obj.name,A.name],A.dimensionality,...
                obj.value.*A);
        end
        function C = mtimes(obj,A)
            C = obj.*A;
        end
    end
end
