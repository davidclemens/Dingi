classdef bitmask
    % BITMASK  Encodes binary flags in decimal arrays
    % The bitmask class encodes binary flags in decimal arrays by setting
    % individual bits to high or low. It also chooses the most efficient
    % storage type for the bits that are set.
    %
    % BITMASK Properties:
    %   StorageTypeName - Current storage type
    %   Bits - Decimal bitmask array
    %   Size - Bitmask size
    %
    % BITMASK Methods:
    %   bitmask - Constructor method
    %   setBit - Set specific bits at specific indices
    %   setNum - Set decimal numbers at specific indices
    %   isBit - Test if a bit is set
    %   disp - Display a bitmask instance in the command line
    %
    % Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
    %

    % Frontend
    properties (Dependent)
        StorageTypeName char % Current storage type name
        Bits % Decimal bitmask array
        Size double % Bitmask size
    end

    % Backend
    properties (Access = private)
        Bits_ = uint8.empty
        StorageTypeName_ char = 'uint8'
        StorageType_ uint8 = 8
    end
    properties (Access = protected, Dependent)
        StorageType double % Number of bits of the current storage type
    end
    properties (Access = private, Constant)
        MaxNumber = intmax('uint64')
        validStorageTypeNames = {'uint8','uint16','uint32','uint64'}
        validStorageTypes uint8 = 2.^(3:6)
    end

    % Constructor method
    methods
        function obj = bitmask(varargin)
            % bitmask  Bitmask constructor method
            %   BITMASK constructs a bitmask instance.
            %
            %   Syntax
            %     obj = BITMASK(A)
            %     obj = BITMASK(m,n)
            %     obj = BITMASK(i,j,bit)
            %     obj = BITMASK(i,j,bit,m,n)
            %
            %   Description
            %     obj = BITMASK(A) converts a decimal array A into a bitmask. It holds
            %       the same number and shape as A. The values in A are assumed to
            %       encode up to 64 bits. Hence, no value in A can exceed
            %       intmax('uint64'). The storage type is optimized, meaning that if
            %       only the first 8 bits are set, the bitmask is stored as uint8.
            %     obj = BITMASK(m,n) creates an m-by-n bitmask with all bits set to
            %       zero.
            %     obj = BITMASK(i,j,bit) creates a max(i(:)) x max(j(:)) bitmask with
            %       bits bit at indices (i,j) set to high.
            %     obj = BITMASK(i,j,bit,m,n) additionally specifies the size of the
            %       bitmask array.
            %
            %   Example(s)
            %     obj = BITMASK(magic(5))
            %     obj = BITMASK(3,5) creates a 3x5 bitmask with all zeros.
            %     obj = BITMASK(2,3,9) creates a 2x3 bitmask with bit 9 at index (2,3)
            %       set to 1. It is stored as uint16.
            %     obj = BITMASK(2,3,9,5,10) creates a 5x10 bitmask with bit 9 at index
            %       (2,3) set to 1. It is stored as uint16.
            %     obj = BITMASK([2,1],[3,8],[2,9],5,10) creates a 5x10 bitmask with bit
            %       2 at index (2,3) and bit 9 at index (1,8) set to 1. It is stored as
            %       uint16.
            %
            %
            %   Input Arguments
            %     A - Input Matrix
            %       scalar | vector | matrix
            %         Input matrix, specified as a numeric matrix with no value
            %         exceeding intmax('uint64').
            %
            %     i, j - Subscript pairs (as seperate arguments)
            %       scalar | vector
            %         Subscript pairs, specified as separate arguments of scalars,
            %         vectors, or matrices. Corresponding elements in i and j specify
            %         subscript pairs into the bitmask, which determine the setting
            %         of the bit into the output.
            %
            %     bit - Bit position to be enabled
            %       scalar | vector
            %         Bit positions which should be enabled, specified as a scalar or
            %         vector. Any elements in bit that are zero are ignored, as are the
            %         corresponding subscripts in i and j. However, if you do not
            %         specify the dimension sizes of the output, m and n, then
            %         bitmask calculates the maxima m = max(i(:)) and n = max(j(:))
            %         before ignoring any zero elements in bit.
            %
            %     m, n - Size of each dimension (as separate arguments)
            %       integer values
            %         Size of each dimension of the bitmask matrix, specified as
            %         separate arguments of integer values. If you specify m (the row
            %         size), you also must specify n (the column size).
            %         If you do not specify m and n, then bitmask uses the
            %         default values m = max(i(:)) and n = max(j(:)). These maxima are
            %         computed before any zeros in bit are removed. Note that even
            %         though the constructor only accepts 2D arrays, after creation the
            %         bitmask array can be extended to N-dimensional arrays using the
            %         setBit or setNum methods.
            %
            %
            %   Name-Value Pair Arguments
            %
            %
            %   See also SETBIT, SETNUM
            %
            %   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
            %

            switch nargin
                case 0
                    return
                case 1
                    obj         = obj.setNum(varargin{1});
                    return
                case 2
                    sz          = cat(2,varargin{1:2});
                    obj         = obj.setNum(zeros(sz));
                    return
                case 3
                    i           = varargin{1}(:);
                    j           = varargin{2}(:);
                    bit         = varargin{3}(:);
                    sz          = [];
                case 5
                    i           = varargin{1}(:);
                    j           = varargin{2}(:);
                    bit         = varargin{3}(:);
                    sz          = cat(2,varargin{4:5});
                otherwise
                    error('Dingi:DataKit:bitmask:invalidNumberOfInputs',...
                        'Invalid number of inputs.')
            end
            obj = initializeBitmask(obj,i,j,bit,sz);
        end
    end

    methods
        obj = setBit(obj,bit,highlow,varargin)
        obj = setNum(obj,num,varargin)
        tf = isBit(obj,bit)
    end

    % Overloaded methods
    methods
        disp(obj,varargin)
        varargout = subsref(obj,s)
        obj = subsasgn(obj,s,b)
        obj = cat(dim,varargin)
        varargout = size(obj,varargin)
        obj = reshape(obj,varargin)
        obj = and(objA,objB)
        obj = or(objA,objB)
        obj = horzcat(varargin)
        obj = vertcat(varargin)
        obj = permute(obj,order)
        obj = transpose(obj)
        obj = ctranspose(obj)
    end

    methods (Access = private)
        obj = initializeBitmask(obj,i,j,bit,sz)
        obj = changeStorageType(obj,newStorageType)
        storageType = minStorageType(obj,A)
        obj = extendBitmask(obj,varargin)
    end

    % Static methods
    methods (Access = private, Static)
        intout = setbits(bits)
    end

    % Get methods
    methods
        function bits = get.Bits(obj)
            bits = obj.Bits_;
        end
        function storageTypeName = get.StorageTypeName(obj)
            storageTypeName = obj.StorageTypeName_;
        end
        function storageType = get.StorageType(obj)
            storageType = obj.StorageType_;
        end
        function sz = get.Size(obj)
            sz = size(obj.Bits_);
        end
    end

    % Set methods
    methods
        function obj = set.Bits_(obj,newNum)
            dbs = dbstack(1,'-completenames');
            caller         = dbs(1).file;
            validCallers   = {'@bitmask/setBit.m';
                              '@bitmask/setNum.m';
                              '@bitmask/changeStorageType.m';
                              '/load.m'}; % When the object is loaded, this set method is called. Therefore, any load method should be permitted to set the Bits_ property.
            if ~endsWith(caller,validCallers)
                error('Dingi:DataKit:bitmask:setDotBits_:invalidCaller',...
                    'Invalid caller ''%s''.',caller)
            end
            obj.Bits_           = newNum;
        end
        function obj = set.Bits(obj,newNum)

            % Determine smallest storage type which holds all information of array
            % 'value'. And make this the new storage type.
            obj = obj.setNum(newNum);
        end
        function obj = set.StorageTypeName(obj,value)

            % To avoid load order dependeces, the 'StorageTypeName' property is a dependent
            % property, which retrieves the value of the property 'StorageTypeName_'.
            % Search for 'Avoid Property Initialization Order Dependency' in the
            % documentation.

            newStorageTypeName = validatestring(value,obj.validStorageTypeNames);

            obj = changeStorageType(obj,newStorageTypeName);
        end
        function obj = set.StorageType(obj,value)

            % To avoid load order dependeces, the 'StorageType' property is a dependent
            % property, which retrieves the value of the property 'StorageType_'.
            % Search for 'Avoid Property Initialization Order Dependency' in the
            % documentation.

            if ismember(value,obj.validStorageTypes)
                newStorageTypeName = value;
            else
                error('Invalid storage type ''%u''. Valid types are: %s.',value,strjoin(cellstr(string(2.^(3:6))),', '))
            end

            obj = changeStorageType(obj,newStorageTypeName);
        end
    end
end
