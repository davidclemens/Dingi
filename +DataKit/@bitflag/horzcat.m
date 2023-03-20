function obj = horzcat(varargin)
% horzcat  Concatenate bitflags horizontally
%   HORZCAT concatenates bitflags horizontally.
%
%   Syntax
%     C = HORZCATCAT(A1,...,AN)
%
%   Description
%     C = HORZCATCAT(dim,A,B)  horizontally concatetnates bitflags A1,...,AN.
%
%   Example(s)
%
%
%   Input Arguments
%     A1,...,AN - input bitflags
%       DataKit.bitflag
%         Multiple bitflags to be concatetenated, specified as a
%         DataKit.bitflag.
%
%
%   Output Arguments
%     C - concatenated bitflags
%       DataKit.bitflag
%         The concatenated bitflags returned as a DataKit.bitflag.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAKIT.BITFLAG.CAT, DATAKIT.BITFLAG.VERTCAT, DATAKIT.BITFLAG
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = cat(2,varargin{:});
end
