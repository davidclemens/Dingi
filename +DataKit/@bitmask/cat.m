function obj = cat(dim,varargin)
% cat  Concatenate bitmasks
%   CAT concatenates bitmasks along the specified dimension.
%
%   Syntax
%     C = CAT(dim,A,B)
%     C = CAT(dim,A1,A2,A3,A4,...)
%
%   Description
%     C = CAT(dim,A,B)  Concatetnates bitmasks A and B along the dimension
%       specified by dim.
%     C = CAT(dim,A1,A2,A3,A4,...)  Concatetnates all the input bitmasks (A1,
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
%     A - first input bitmask
%       DataKit.bitmask
%         The first bitmask to be concatetenated, specified as a
%         DataKit.bitmask.
%
%     B - second input bitmask
%       DataKit.bitmask
%         The second bitmask to be concatetenated, specified as a
%         DataKit.bitmask.
%
%     A1,A2,A3,A4,... - input bitmasks
%       DataKit.bitmask
%         Multiple bitmasks to be concatetenated, specified as a
%         DataKit.bitmask.
%
%
%   Output Arguments
%     C - concatenated bitmask
%       DataKit.bitmask
%         The concatenated bitmask returned as a DataKit.bitmask.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITMASK.VERTCAT, DATAKIT.BITMASK.HORZCAT, DATAKIT.BITMASK
%
%   Copyright (c) 2022-2023 David Clemens (dclemens@geomar.de)
%
    
    uClassNames = unique(cellfun(@(in) class(in),varargin,'un',0));
    
    if numel(uClassNames) ~= 1
        error('Dingi:DataKit:bitmask:cat:differingInputTypes',...
            'All inputs must be the same type.')
    end
    
    obj     = varargin{1};
    
    % extract all bitmasks
    bms    = cellfun(@(in) in.Bits,varargin,'un',0);
    
    % concatenate the bitmask
    bm     = cat(dim,bms{:});
    
    % create new bitmask object
    obj.Bits = bm;
end
