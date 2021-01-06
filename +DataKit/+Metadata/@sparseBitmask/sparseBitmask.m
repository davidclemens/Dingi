classdef sparseBitmask
    
    properties (SetAccess = private)
        Bitmask double = sparse(double.empty)
    end
    properties (Dependent)
        Sz double
    end
    
    methods
        function obj = sparseBitmask(varargin)
        % sparseBitmask  Create sparse bit flag matrix.
        %   SPARSEBITMASK creates a sparseBitmask instance, whicht holds a 2D
        %   sparse matrix with integer values, encoding bitmasks with up to 52
        %   bits.
        %
        %   Syntax
        %     obj = sparseBitmask(A)
        %     obj = sparseBitmask(m,n)
        %     obj = sparseBitmask(i,j,bit)
        %     obj = sparseBitmask(i,j,bit,m,n)
        %
        %   Description
        %     obj = sparseBitmask(A) converts a full matrix into a sparse bitmask
        %     object. It holds the same number and shape of bitmasks as A. The
        %     values in A are assumed to encode 52 bits. Hence, no value in A can
        %     exceed 2⁵².
        %
        %     obj = sparseBitmask(m,n) generates a sparse bitmask object with
        %     m-by-n 52-bit bitmasks with all bits set to zero.
        %
        %     obj = sparseBitmask(i,j,bit) generates sparse bitmask object with
        %     max(i)-by-max(j) bitmasks and the bits at position bit set to 1.
        %     Bits bit with duplicate subscripts in i and j are combined with the
        %     logical or operation.
        %
        %     obj = sparseBitmask(i,j,bit,m,n) additionally specifies the size of
        %     the bitmask array.
        %
        %   Example(s)
        %     obj = sparseBitmask(magic(5))
        %
        %
        %   Input Arguments
        %     A - Input Matrix
        %       scalar | vector | matrix
        %         Input matrix, specified as a numeric matrix with no value
        %         exceeding 2⁵².
        %
        %         Note: This limitation exists, since sparse matrices in MATLAB are
        %         of type double, which is a floating point number with 64 bits. 52
        %         of those bits are used to represent the fraction and thus the
        %         longest consecutive chain of integers representable as a float is
        %         0 to 2⁵².
        %
        %     i, j - Subscript pairs (as seperate arguments)
        %       scalar | vector
        %         Subscript pairs, specified as separate arguments of scalars,
        %         vectors, or matrices. Corresponding elements in i and j specify
        %         subscript pairs into the bitmask, which determine the setting
        %         of the bit into the output. If i and j have identical values for
        %         several elements in bit, then those elements are combined
        %         together with the logical or operation.
        %
        %     bit - Bit position to be enabled
        %       scalar | vector
        %         Bit positions which should be enabled, specified as a scalar or
        %         vector. Any elements in bit that are zero are ignored, as are the
        %         corresponding subscripts in i and j. However, if you do not
        %         specify the dimension sizes of the output, m and n, then
        %         sparseBitmask calculates the maxima m = max(i) and n = max(j)
        %         before ignoring any zero elements in bit.
        %
        %     m, n - Size of each dimension (as separate arguments)
        %       integer values
        %         Size of each dimension of the bitmask matrix, specified as
        %         separate arguments of integer values. If you specify m (the row
        %         size), you also must specify n (the column size).
        %         If you do not specify m and n, then sparseBitmask uses the
        %         default values m = max(i) and n = max(j). These maxima are
        %         computed before any zeros in bit are removed.
        %
        %
        %   Output Arguments
        %
        %     obj - sparseBitmask instance
        %       sparseBitmask
        %         An instance of the sparseBitmask class that holds the bitmask as
        %         defined by the inputs.
        %
        %
        %   Name-Value Pair Arguments
        %
        %
        %   See also SPARSE, DATAFLAG
        %
        %   Copyright 2021 David Clemens (dclemens@geomar.de)
        %

            switch nargin
                case 0
                    return
                case 1
                    obj.Bitmask	= sparse(varargin{1});
                    return
                case 2
                    sz          = cat(2,varargin{1:2});
                    obj.Bitmask	= sparse(zeros(sz));
                    return
                case 3
                    i       = varargin{1}(:);
                    j       = varargin{2}(:);
                    bit     = varargin{3}(:);
                    sz      = [];
                case 5
                    i       = varargin{1}(:);
                    j       = varargin{2}(:);
                    bit     = varargin{3}(:);
                    sz      = cat(2,varargin{4:5});
                otherwise
                    error('DataKit:Metadata:sparseBitmask:invalidNumberOfInputs',...
                        'Invalid number of inputs.')
            end
            obj = initializeBitmask(obj,i,j,bit,sz);
        end
    end
    
    methods
        disp(obj)
        obj = initializeBitmask(obj,i,j,bit,sz)
        obj = setBit(obj,i,j,bit,highlow)
        varargout = getBit(obj,varargin)
    end
    methods (Static, Hidden)
        intout = setbits(bits)
    end
    
    methods % overloaded
        varargout = subsref(obj,s)
        obj = cat(dim,varargin)
        obj = horzcat(varargin)
        obj = vertcat(varargin)
        varargout = size(obj,varargin)
    end
    
    methods % Get methods
        function Sz = get.Sz(obj)
            Sz = size(obj);
        end
    end
    
    methods % Set methods
        function obj = set.Bitmask(obj,value)
            % warn if bitmask changes size and will be very wide, because a
            % wide sparse array with mostly 0s consumes tremendously more
            % memory than a tall sparse array with mostly 0s.
            if ~all(size(obj.Bitmask) == size(value)) && size(value,2) > 100
                warning('DataKit:Metadata:sparseBitmask:widerThanTallShape',...
                    'The bitmask is shaped very wide. Consider shaping it tall to save considerable memory.')
            end
            obj.Bitmask = value;
        end
    end
end