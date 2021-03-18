function varargout = addPool(obj)
% addPool  Adds a pool to the dataPool instance
%   ADDPOOL adds an empty pool to the dataPool instance obj.
%
%   Syntax
%     ADDPOOL(obj)
%     obj = ADDPOOL(__)
%
%   Description
%     ADDPOOL(obj) adds an empty pool to the dataPool instance obj.
%     obj = ADDPOOL(__) additionally returns the dataPool handle.
%
%   Example(s)
%     ADDPOOL(obj)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%
%   Output Arguments
%     obj - returned data pool instance
%       DataKit.dataPool
%         The new instance of the DataKit.dataPool class.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAPOOL
%
%   Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
%

    nargoutchk(0,1);

    pool                    = obj.PoolCount + 1;
    obj.DataRaw(pool)     	= {NaN(0,0)};
    obj.Data(pool)          = {NaN(0,0)};
    obj.Flag(pool)          = {zeros(0,0,'uint32')};
    obj.Uncertainty(pool)	= {sparse(zeros(0,0))};
    obj.Info(pool)          = DataKit.Metadata.info;
    
    if nargout == 1
        varargout{1} = obj;
    end
end