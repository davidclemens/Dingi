function obj = setFlag(obj,flag,highlow,varargin)
% setFlag  Sets bitflag flags
%   SETFLAG sets the flag(s) of a bitflag at specific indices to high or
%   low.
%
%   Syntax
%     obj = SETFLAG(obj,flag,highlow,i,j)
%     obj = SETFLAG(obj,flag,highlow,dim1,...,dimN)
%
%   Description
%     obj = SETFLAG(obj,flag,highlow,i,j) sets flag(s) flag at indices 
%       (i,j) of bitflag obj to high or low according to highlow.
%     obj = SETFLAG(obj,flag,highlow,dim1,...,dimN) sets flag(s) flag at
%       indices (dim1,...,dimN) of bitflag obj to high or low according to
%       highlow.
%
%   Example(s)
%     obj = SETFLAG(obj,3,1,1,2) sets flag 3 of element (1,2) of bitflag
%       obj to high.
%     obj = SETFLAG(obj,1:2,1,1,2:3) sets flag 1 of element (1,2) and flag
%       2 of element (1,3) of bitflag obj to high.
%
%
%   Input Arguments
%     obj - bitflag instance
%       DataKit.bitflag
%         A DataKit.bitflag instance.
%
%     flag - Flag to be set
%       char | cellstr | numeric | enumeration
%         Flag which should be enabled, specified as a scalar or vector of type
%         char, cellstr, numeric or the specified enumeration class. Char &
%         cellstr are checked against the enumeration member names and numeric
%         values are checked against the enumeration member ids. Only valid
%         flags are allowed.
%
%     highlow - Flag value
%       scalar | numeric array
%         Flag value, specified as a scalar or a numeric array. flag, highlow
%         and dim1,...,dimN can each be scalars or arrays of the same size.
%           - If highlow is zero, then the flags flag are set to 0 (off).
%           - If highlow is nonzero, then the flags flag are set to 1 (on).
%
%     dim1,...,dimN - Bitflag subscripts
%       vectors
%         Dimension subscript vectors, indexing into the bitflag.
%
%
%   Output Arguments
%     obj - DataKit.bitflag instance
%       DataKit.bitflag
%         A DataKit.bitflag instance.
%
%
%   Name-Value Pair Arguments
%
% 
%   Note:
%     If the same flag at the same index is adressed multiple times with
%     differing highlow values, it will be set to the last occurance of the
%     highlow value for that index.
%       Example:
%           SETFLAG(obj,[4,4,4,3],[0,0,0,1],2,3) results in
%               (2,3) ...0100
%           while SETFLAG(obj,[4,4,4,3],[1,0,1,1],2,3) results in
%               (2,3) ...1100
%
%
%   See also BITFLAG
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    import DataKit.bitflag.validateFlag
    
    % Check number of input arguments
    narginchk(5,inf)
    
    % Validate flags
    flagId = validateFlag(obj.EnumerationClassName,flag);
    
    % Set the bits of the underlying bitmask
    obj = obj.setBit(flagId,highlow,varargin{:});
end