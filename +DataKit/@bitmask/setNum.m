function obj = setNum(obj,num,varargin)
% setNum  Sets bitmask decimal numbers
%   SETNUM sets the decimal number of a bitmask at a specific index.
%
%   Syntax
%     obj = SETNUM(obj,num)
%     obj = SETNUM(obj,num,ind)
%     obj = SETNUM(obj,num,dim1Sub,...,dimNSub)
%
%   Description
%     obj = SETNUM(obj,num) replaces the current bitmask with the array
%       num.
%     obj = SETNUM(obj,num,ind) sets the decimal number at the linear index
%       ind of bitmask obj to num.
%     obj = SETNUM(obj,num,dim1,...,dimN) the decimal number at subscripts
%       (dim1,...,dimN, with N >= 2) of bitmask obj to num.
%
%   Example(s)
%     obj = SETNUM(obj,zeros(5)) creates a new 5x5 bitmask with all zeros.
%     obj = SETNUM(obj,3,10) where obj is a 3x2 bitmask sets element (1,4)
%       of bitmask obj to 3. Note that the bitmask is now of size (3,4) as
%       the linear index exceeded the number of elements. The bitmask was
%       grown along the first dimension.
%     obj = SETNUM(obj,3,1,2) sets element (1,2) of bitmask obj to 3,
%       setting all bits to low while bit 1 & 2 are set to high.
%     obj = SETNUM(obj,1:3,1,5:8,2) sets elements (5,2), (6,2) and (7,2) to
%       1, 2 and 3 respectively, setting all bits to low while bits (1),
%       (2) and (1 & 2) are respectively set to high.
%
%
%   Input Arguments
%     obj - DataKit.bitmask instance
%       DataKit.bitmask
%         A DataKit.bitmask instance.
%
%     num - Decimal number
%       integer | integer array
%         Decimal number, specified as an integer or integer array. num,
%         and dim1,...,dimN can each be scalars or arrays of the
%         same size. The values of num must be between 0 and
%         intmax('uint64').
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
%         Dimension subscript vectors, indexing into the bitmask. If the
%         subscript exceeds the bitmask size, the bitmask is grown
%         accordingly.
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
%     If the same index is adressed multiple times with differing num
%     values, it will be set to the last occurance of the num value for
%     that index.
%       Example:
%           SETNUM(obj,[4,4,4,3],2,3) results in
%               (2,3) ...0011
%           while SETNUM(obj,[4,4,4,5],2,3) results in
%               (2,3) ...0101
%
%
%   See also BITMASK, SETBIT
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    import DataKit.arrayhom
    import DebuggerKit.Debugger.printDebugMessage

    % Check number of input arguments
    narginchk(2,inf)
    
    % Determine appropriate storage type
    storageType = obj.minStorageType(num);
    if ~isa(num,storageType)
        num = cast(num,storageType);
    end
    
    if nargin == 2
        % No index is given. Replace the current bitmask with num.
        obj         = obj.changeStorageType(storageType);
        obj.Bits_ 	= num;
        obj        	= obj.changeStorageType(storageType);
        return
    elseif nargin == 3
        % Only 1 index is given. Interpret it as a linear index into the bitmask.
        % If the linear index > prod(obj.Size) the array grows along the first
        % dimension.
        subs       	= cell(1,ndims(obj.Bits));
        [subs{:}]	= ind2sub(obj.Size,varargin{:});
        varargin    = subs;
    end
    
	if isempty(num) || any(cellfun(@isempty,varargin))
        % If any of the relevant inputs is empty return the original object
        return
	end
    
    % Homogonize the input arrays
    [num,varargin{:}] = arrayhom(num,varargin{:});
    
    % Extend bitmask if necessary
    obj = extendBitmask(obj,varargin{:});
    
    % Convert subscripts to a linear index
    ind = sub2ind(obj.Size,varargin{:});
    
    % Reshape inputs
    ind = reshape(ind,[],1);
    num = reshape(num,[],1);
    
    % Set storage type and assign the new bitmask numbers
    obj             = obj.changeStorageType(storageType);
    obj.Bits_(ind)  = num;
    obj             = obj.changeStorageType(storageType);
end