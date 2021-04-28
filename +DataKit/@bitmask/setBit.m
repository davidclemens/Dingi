function obj = setBit(obj,bit,highlow,varargin)
% setBit  Sets bitmask bits
%   SETBIT sets the bit(s) of a bitmask at a specific index to high or low.
%
%   Syntax
%     obj = SETBIT(obj,bit,highlow,ind)
%     obj = SETBIT(obj,bit,highlow,dim1,...,dimN)
%
%   Description
%     obj = SETBIT(obj,bit,highlow,ind) sets bit(s) bit at linear indices
%       ind of bitmask obj to high or low according to highlow.
%     obj = SETBIT(obj,bit,highlow,dim1,...,dimN) sets bit(s) bit at
%       subscripts (dim1,...,dimN, with N >= 2) of bitmask obj to high or
%       low according to highlow.
%
%   Example(s)
%     obj = SETBIT(obj,3,1,1,2) sets bit 3 of element (1,2) of bitmask obj
%       to high.
%     obj = SETBIT(obj,3,1,10) where obj is a 3x2 bitmask sets bit 3 for 
%       element (1,4) of bitmask obj to high. Note that the bitmask is now 
%       of size (3,4) as the linear index exceeded the number of elements. 
%       The bitmask was grown along the first dimension.
%     obj = SETBIT(obj,1:2,1,1,2:3) sets bit 1 of element (1,2) and bit 2
%       of element (1,3) of bitmask obj to high.
%
%
%   Input Arguments
%     obj - DataKit.bitmask instance
%       DataKit.bitmask
%         A DataKit.bitmask instance.
%
%     bit - Bit position
%       integer | integer array
%         Bit position, specified as an integer or integer array. bit,
%         highlow and dim1,...,dimN can each be scalars or arrays of the
%         same size. The values of bit must be between 1 (the least
%         significant bit) and 64.
%
%     highlow - Bit value
%       scalar | numeric array
%         Bit value, specified as a scalar or a numeric array. bit, highlow
%         and dim1,...,dimN can each be scalars or arrays of the same size.
%           - If highlow is zero, then the bit position bit is set to 0
%             (off).
%           - If highlow is nonzero, then the bit position bit is set to 1
%             (on).
%
%     ind - Bitmask linear index
%       vectors
%         Linear index into the bitmask.
%         Note: If the linear index exceeds the number of bitmask elements,
%         the bitmask is grown along its first dimension to accomodate the
%         linear index.
%
%     dim1,...,dimN - Bitmask subscripts
%       vectors
%         Dimension subscript vectors, indexing into the bitmask.
%
%
%   Output Arguments
%     obj - DataKit.bitmask instance
%       DataKit.bitmask
%         A DataKit.bitmask instance.
%
%
%   Name-Value Pair Arguments
%
% 
%   Note:
%     If the same bit at the same index is adressed multiple times with
%     differing highlow values, it will be set to the last occurance of the
%     highlow value for that index.
%       Example:
%           SETBIT(obj,[4,4,4,3],[0,0,0,1],2,3) results in
%               (2,3) ...0100
%           while SETBIT(obj,[4,4,4,3],[1,0,1,1],2,3) results in
%               (2,3) ...1100
%
%
%   See also BITMASK, SETNUM
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    import DataKit.arrayhom
    
    % Check number of input arguments
    narginchk(4,inf)
    
    if nargin == 4
        % Only 1 index is given. Interpret it as a linear index into the bitmask.
        % If the linear index > prod(obj.Size) the array grows along the first
        % dimension.
        subs       	= cell(1,ndims(obj.Bits));
        [subs{:}]	= ind2sub(obj.Size,varargin{:});
        varargin    = subs;
    end
	if isempty(bit) || isempty(highlow) || any(cellfun(@isempty,varargin))
        % If any of the relevant inputs is empty return the original object
        return
	end
    
    % Extend bitmask if necessary
    obj = extendBitmask(obj,varargin{:});
    
    % Convert subscripts to a linear index
    ind = sub2ind(obj.Size,varargin{:});
    
    % Reshape inputs
    ind     = reshape(ind,[],1);
    bit     = reshape(bit,[],1);
    highlow = reshape(highlow,[],1);
    
    % Homogonize the input arrays
    [ind,bit,highlow] = arrayhom(ind,bit,highlow);
    
    % Extract the relevant bitmask numbers
    Ain = reshape(obj.Bits_(ind),[],1);
    
    % Find unique linear indices
    [uInd,~,uIndInd2] = unique(ind);
    
    % Determine appropriate storage type
    storageType = obj.minStorageType(2^max(uint64(bit)));
    
    if ~isa(Ain,storageType)
        Ain = cast(Ain,storageType);
    end
    
    % Set all specified bits to highlow
 	Ain = bitset(Ain,bit,highlow);
    
    % Only keep the last bit that was set if there are equal linear indices
    Aout = accumarray(uIndInd2,Ain,size(uInd),@(x) x(end));
    
    % Set storage type and assign the new bitmask
    obj             = obj.changeStorageType(storageType);
    obj.Bits_(uInd) = Aout;
    obj             = obj.changeStorageType(storageType);
end