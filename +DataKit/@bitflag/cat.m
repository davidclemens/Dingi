function obj = cat(dim,varargin)
% cat  Concatenate bitflags
%   CAT concatenates bitflags along the specified dimension.
%
%   Syntax
%     C = CAT(dim,A,B)
%     C = CAT(dim,A1,A2,A3,A4,...)
%
%   Description
%     C = CAT(dim,A,B)  Concatetnates bitflags A and B along the dimension
%       specified by dim.
%     C = CAT(dim,A1,A2,A3,A4,...)  Concatetnates all the input bitflags (A1,
%       A2, A3, A4, and so on) along dimension specified by dim.
%
%   Example(s)
%
%
%   Input Arguments
%     dim - concatenation dimension
%       positive integer scalar
%         The concatenation dimension, specified as a real, positive, integer
%         value.
%
%     A - first input bitflag
%       DataKit.bitflag
%         The first bitflag to be concatetenated, specified as a
%         DataKit.bitflag.
%
%     B - second input bitflag
%       DataKit.bitflag
%         The second bitflag to be concatetenated, specified as a
%         DataKit.bitflag.
%
%     A1,A2,A3,A4,... - input bitflags
%       DataKit.bitflag
%         Multiple bitflags to be concatetenated, specified as a
%         DataKit.bitflag.
%
%
%   Output Arguments
%     C - concatenated bitflag
%       DataKit.bitflag
%         The concatenated bitflag returned as a DataKit.bitflag.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITFLAG.VERTCAT, DATAKIT.BITFLAG.HORZCAT, DATAKIT.BITFLAG
%
%   Copyright (c) 2022-2023 David Clemens (dclemens@geomar.de)
%

    % Remove empty inputs
    varargin = varargin(~cellfun(@isempty,varargin));
    
    % Check if all inputs are bitflags
    assert(all(cellfun(@(a) isa(a,'DataKit.bitflag'),varargin)),...
        'DataKit.bitflag:cat:TypeError',...
        'All inputs need to be of type DataKit.bitflag.')
    
    % Check if all inputs are of the same enumeration class name
    enumerationClassNames = cellfun(@(a) a.EnumerationClassName,varargin,'un',0);
    assert(numel(unique(enumerationClassNames)) == 1,...
        'DataKit:bitflag:cat:EnumerationClassMissmatch',...
        'The enumeration class names have to match.')
    
    % Concatenate the bitmasks
    bitsC   = cat@DataKit.bitmask(dim,varargin{:});
    
    % Construct a new bitflag instance
    obj     = DataKit.bitflag(varargin{1}.EnumerationClassName,bitsC.Bits);    
end
