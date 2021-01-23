function varargout = getBit(obj,varargin)
% getBit  Retrieves the position of high bits in a sparse bitmask.
%   GETBIT retrieves the position of high bits in the sparse bitmask at
%   subscript pairs i-j.
%
%   Syntax
%     getBit(obj)
%     getBit(obj,i,j)
%     bits = getBit(__)
%     [i,j,bit] = getBit(__)
%
%   Description
%
%
%   Input Arguments
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also SETBIT
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    import DataKit.arrayhom
 
    if nargin == 1
        [i,j] = find(obj.Bitmask);
    elseif nargin == 3
        [i,j] = arrayhom(varargin{1},varargin{2});
    else
        error('DataKit:Metadata:sparseBitmask:getBit:invalidNumberOfArguments',...
            'Invalid number of arguments.')        
    end
    
    n       = numel(i);
    out     = cell(n,1);
    iout    = cell(n,1);
    jout    = cell(n,1);
    for ii = 1:n
        out{ii}     = find(bitget(full(obj.Bitmask(i(ii),j(ii))),1:52))';
        nout        = numel(out{ii});
        iout{ii}    = repmat(i(ii),nout,1);
        jout{ii}    = repmat(j(ii),nout,1);
    end
    if nargout <= 1
        varargout{1}    = out;
    elseif nargout == 3
        varargout{1}    = cat(1,iout{:});
        varargout{2}    = cat(1,jout{:});
        varargout{3}    = cat(1,out{:});
    else
        error('DataKit:Metadata:sparseBitmask:getBit:invalidNumberOfOutputVariables',...
            'Invalid number of output variables.')
    end
end