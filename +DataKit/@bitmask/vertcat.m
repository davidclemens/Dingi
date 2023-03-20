function obj = vertcat(varargin)
% vertcat  Concatenate bitmasks vertically
%   VERTCAT concatenates bitmasks vertically.
%
%   Syntax
%     C = VERTCAT(A1,...,AN)
%
%   Description
%     C = VERTCAT(dim,A,B)  vertically concatetnates bitmasks A1,...,AN.
%
%   Example(s)
%
%
%   Input Arguments
%     A1,...,AN - input bitmasks
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
%   See also DATAKIT.BITMASK.CAT, DATAKIT.BITMASK.HORZCAT, DATAKIT.BITMASK
%
%   Copyright (c) 2023-2023 David Clemens (dclemens@geomar.de)
%

    obj = cat(1,varargin{:});
end

