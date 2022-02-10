function varargout = arrayhom(varargin)
% arrayhom  Homogenizes arrays with varying shapes.
%   ARRAYHOM homogenizes multiple arrays with varying input shapes to
%   column vectors if possible.
%
%   Syntax
%     [out1,...,outN] = ARRAYHOM(in1,...,inN)
%
%   Description
%     [out1,...,outN] = ARRAYHOM(in1,...,inN) homogenizes inputs in1 to
%     inN. Scalar inputs are repeated to match the shape of non-scalar
%     inputs. All non-scalar inputs have to have the same shape. All
%     outputs are column vectors.
%
%   Example(s)
%     [out1,out2] = ARRAYHOM(1,[20,3,5])
%         out1 = [1;1;1]
%         out2 = [20;3;5]
%     [out1,out2] = ARRAYHOM([20,3;5,7],4)
%         out1 = [20;5;3;7]
%         out2 = [4;4;4;4]
%     [out1,out2] = ARRAYHOM([20,3;5,7],[2,10;3,9])
%         out1 = [20;5;3;7]
%         out2 = [2;3;10;9]
%
%
%   Input Arguments
%     In1,...,InN - Input arrays
%       scalar | vector | matrix
%         Input arrays to be homogenized. All non-scalar inputs have to
%         have the same shape.
%
%
%   Output Arguments
%     Out1,...,OutN - Output arrays
%       column vector
%         The homogenized outputs as column vectors
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    maxDim      = 1;
    nvarargin   = numel(varargin);
    dims        = max(cellfun(@ndims,varargin));
    Sz          = ones(nvarargin,dims);
    for dim = 1:dims
        Sz(:,dim) = cellfun(@(in) size(in,dim),varargin)';
    end
    SzAllSingleton     = all(Sz == 1,2);
    
    [uSz,~,uSzInd] = unique(Sz,'rows');
    
    nNonAllSingletonInputs        	= size(Sz(~SzAllSingleton,:),1);
    if nNonAllSingletonInputs > 1
        % more than 1 non-singleton size exists
        allNonSingletonSizesAreEqual    = all(all(diff(Sz(~SzAllSingleton,:),1,1) == 0,1));
    else
        % only 1 non-singleton size exists
        allNonSingletonSizesAreEqual    = true;
    end
    
    if ~allNonSingletonSizesAreEqual && nNonAllSingletonInputs > dims - 1
        error('Dingi:DataKit:arrayhom:invalidNumberOfSingletonDimensions',...
            'Too many unique non-singleton shapes.')
    end
    
    [~,indShapeRepmat]  = max(sum(uSz,2));
    shapeRepmat         = uSz(indShapeRepmat,:);
    maskRepmat          = uSzInd ~= indShapeRepmat;
    
    reshapeSz           = cat(2,repmat({[]},1,maxDim),{1});
    
    varargout   = cell(size(varargin));
    for ii = 1:nvarargin
        if maskRepmat(ii)
            varargout{ii} = reshape(repmat(varargin{ii},shapeRepmat),reshapeSz{:});
        else
            varargout{ii} = reshape(varargin{ii},reshapeSz{:});
        end
    end
end