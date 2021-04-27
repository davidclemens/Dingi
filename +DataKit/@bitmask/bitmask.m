classdef bitmask
    
    % Frontend
    properties (Dependent)
        StorageTypeName char
        Bits
        Size double
    end
    
    % Backend
    properties (Access = private)
        Bits_ = uint8.empty
        StorageTypeName_ char = 'uint8'
        StorageType_ uint8 = 8
    end
    properties (Access = protected, Dependent)
        StorageType double
    end
    properties (Access = protected, Constant)
        MaxNumber = intmax('uint64')
        validStorageTypeNames = {'uint8','uint16','uint32','uint64'}
        validStorageTypes uint8 = 2.^(3:6)
    end
    
    methods
        function obj = bitmask(varargin)
        %     obj = bitmask(A)
        %     obj = bitmask(m,n)
        %     obj = bitmask(i,j,bit)
        %     obj = bitmask(i,j,bit,m,n)
            
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
    
    methods (Access = private)
        obj = initializeBitmask(obj,i,j,bit,sz)
        obj = changeStorageType(obj,newStorageType)
        storageType = minStorageType(obj,A)
        obj = extendBitmask(obj,varargin)
    end
    
    % Overloaded methods
    methods
        obj = subsasgn(obj,s,b)
        obj = cat(dim,varargin)
    end
    
    % Static methods
    methods (Static)
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
                              '@bitmask/changeStorageType.m'};
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