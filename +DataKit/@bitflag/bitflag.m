classdef bitflag < DataKit.bitmask
    % BITFLAG  Encodes enumeration members in bitmasks
    % The bitflag class encodes members of an enumeration class as a bitmask.
    % This is useful for example for data flags.
    %
    % BITFLAG Properties:
    %   EnumerationClassName - Name of the encoded enumeration class
    %   EnumerationMembers - List of the enumeration class' members
    %   EnumerationMemberIds - List of the enumeration class' member ids
    %
    % BITFLAG Methods:
    %   bitflag - Constructor method
    %   setFlag - Set specific flags at a specific indices
    %   isFlag - Test if a flag is set
    %   disp - Display a bitflag instance in the command line
    %
    % Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
    %
    
    % Frontend properties
    properties (Dependent)
        EnumerationClassName char % Name of the encoded enumeration class
        EnumerationMembers % List of the enumeration class' members
        EnumerationMemberIds % List of the enumeration class' member ids
    end
    
    % Backend properties
    properties (Access = private)
        EnumerationClassName_ char = ''
        Bitmask_ DataKit.bitmask = DataKit.bitmask.empty
    end
    properties (Access = private, Dependent)
        MaxEnumerationId
    end
    
    % Constructor method
    methods
        function obj = bitflag(enum,varargin)
            % bitflag  Bitflag constructor method
            %   BITFLAG constructs a bitflag instance.
            %
            %   Syntax
            %     obj = BITFLAG(enum)
            %     obj = BITFLAG(enum,A)
            %     obj = BITFLAG(enum,m,n)
            %     obj = BITFLAG(enum,i,j,flag)
            %     obj = BITFLAG(enum,i,j,flag,m,n)
            %
            %   Description
            %     obj = BITFLAG(enum) creates a bitmask that interpretes each bit
            %       corresponding to the ''Id'' property of the enumeration class enum.
            %     obj = BITFLAG(enum,A) converts a decimal array A into a bitflag. It holds
            %       the same number and shape as A.
            %     obj = BITFLAG(enum,m,n) creates an m-by-n bitflag with all flags set to
            %       id zero.
            %     obj = BITFLAG(enum,i,j,flag) creates a max(i(:)) x max(j(:)) bitflag with
            %       flags flag at indices (i,j) set to high. Flag can be a valid
            %       numeric id or a valid member name of the enumeration class.
            %     obj = BITFLAG(enum,i,j,flag,m,n) additionally specifies the size of the
            %       bitflag array.
            %
            %   Example(s)
            %     obj = BITFLAG('DebuggerKit.debugLevel',1:3) creates a 1x3 bitflag
            %       where (1, 1): FatalError, (1, 2): Error & (1, 3): FatalError,
            %       Error.
            %     obj = BITFLAG('DebuggerKit.debugLevel',3,5) creates a 3x5 bitflag
            %       with all zeros.
            %     obj = BITFLAG('DebuggerKit.debugLevel',2,3,5) creates a 2x3 bitmask with 
            %       flag 5 at index (2,3) set to 1. Flag 5 corresponds to 'Verbose' for
            %       the specified enumeration class.
            %     obj = BITFLAG('DebuggerKit.debugLevel',2,3,4,5,10) creates a 5x10 bitflag
            %        with flag 4 at index(2,3) set to 1. Flag 4 corresponds to 'Info' for
            %       the specified enumeration class.
            %     obj = BITFLAG('DebuggerKit.debugLevel',[2,1],[3,8],[2,5],5,10) creates a
            %       5x10 bitflag with flag 2 at index (2,3) and flag 5 at index (1,8) set 
            %       to 1. This corresponds to 'Verbose' & 'Info' for the specified
            %       enumeration class.
            %
            %
            %   Input Arguments
            %     enum - Enumeration class name
            %       char
            %         The enumeration class name specified as a char in dot notation
            %         (E.g. 'DebuggerKit.debugLevel'). The enumeration class name can
            %         only be set once. It can't be changed after it has been set to a
            %         non-empty value.
            %         The enumeration class is required to have a numeric 'Id' property
            %         that holds unique values starting from 0 ('undefined') and increasing
            %         without a gap. The highest valid id is 64 as the highest storage type
            %         is uint64.
            %
            %     A - Input Matrix
            %       scalar | vector | matrix
            %         Input matrix, specified as a numeric matrix with no value
            %         exceeding intmax('uint64').
            %
            %     i, j - Subscript pairs (as seperate arguments)
            %       scalar | vector
            %         Subscript pairs, specified as separate arguments of scalars,
            %         vectors, or matrices. Corresponding elements in i and j specify
            %         subscript pairs into the bitflag, which determine the setting
            %         of the flag into the output.
            %
            %     flag - Flag to be enabled
            %       char | cellstr | numeric | enumeration
            %         Flag which should be enabled, specified as a scalar or vector of type
            %         char, cellstr, numeric or the specified enumeration class. Char &
            %         cellstr are checked against the enumeration member names and numeric
            %         values are checked against the enumeration member ids. Only valid
            %         flags are allowed.
            %
            %     m, n - Size of each dimension (as separate arguments)
            %       integer values
            %         Size of each dimension of the bitflag matrix, specified as
            %         separate arguments of integer values. If you specify m (the row
            %         size), you also must specify n (the column size).
            %         If you do not specify m and n, then bitflag uses the
            %         default values m = max(i(:)) and n = max(j(:)). Note that even
            %         though the constructor only accepts 2D arrays, after creation the
            %         bitflag array can be extended to N-dimensional arrays using the
            %         setFlag method.
            %
            %
            %   Name-Value Pair Arguments
            %
            %
            %   See also SETFLAG, BITMASK
            %
            %   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
            %
            
            import DataKit.bitflag.validateEnumerationClassName
            
            narginchk(0,6)
            
            % Validate input ids if necessary
            switch nargin - 1
                case {-1,0,1,2}
                    % -1: Handled by superclass constructor: Return empty object
                    %  0: Handled by superclass constructor: Return empty bitflag
                    %  1: Handled by superclass constructor: Convert input array to bitflag array
                    %  2: Handled by superclass constructor: Initialize bitflag array of size m x n
                    %     with all flagId set to 0
                case {3,5}
                    %  3: Initialize bitflag array of size max(i(:)) x max(j(:)) and set bitflag
                    %     at index (i,j) to flagId
                    %  5: Initialize bitflag array of size m x n and set bitflag at index (i,j)
                    %     to flagId
                    
                    % Interpret the flag input correctly depending on the enumeration class
                    % name.
                    validEnumerationClassName = validateEnumerationClassName(enum);
                    varargin{3} = DataKit.bitflag.validateFlag(validEnumerationClassName,varargin{3});
            end
            
            % Call superclass constructor
            obj     = obj@DataKit.bitmask(varargin{:});
            
            % Set the enumeration class name
            obj.EnumerationClassName_ = validateEnumerationClassName(enum);
        end
    end
    
    % Overloaded methods
    methods
        varargout = subsref(obj,s)
        obj = subsasgn(obj,S,varargin)
        disp(obj,varargin)
        obj = reshape(obj,varargin)
        obj = and(objA,objB)
        obj = or(objA,objB)
    end
    
    methods
        obj = setFlag(obj,flag,highlow,varargin)
        tf = isFlag(obj,flag)
    end
    
    methods (Access = private, Static)
        validEnumerationClassName = validateEnumerationClassName(enumerationClassName)
        validFlagId = validateFlag(enumerationClassName,flagId)
    end
    
    % Get methods
    methods
        function enumerationClassName = get.EnumerationClassName(obj)
            enumerationClassName = obj.EnumerationClassName_;
        end
        function enumerationMembers = get.EnumerationMembers(obj)
            info = DataKit.enum.core_listMembersInfo(obj.EnumerationClassName);
            enumerationMembers = cellstr(info{info{:,'Id'} > 0,'EnumerationMemberName'});
        end
        function enumerationMemberIds = get.EnumerationMemberIds(obj)
            enumerationMemberIds = DataKit.enum.listValidPropertyValues(obj.EnumerationClassName,'Id');
        end
        function maxEnumerationId = get.MaxEnumerationId(obj)
            maxEnumerationId = max(obj.EnumerationMemberIds);
        end
    end
    
    % Set methods
    methods
        function obj = set.EnumerationClassName(obj,value)
            if isempty(obj.EnumerationClassName_)
                % Allow setting the enumeration class name after instance creation if it
                % was initialized empty.
                validEnumerationClassName = obj.validateEnumerationClassName(value);
                obj.EnumerationClassName_ = validEnumerationClassName;
            else
                error('Dingi:DataKit:bitflag:setEnumerationClassName:immutableProperty',...
                    'The ''EnumerationClassName'' is immutable.')
            end
        end
    end
end
