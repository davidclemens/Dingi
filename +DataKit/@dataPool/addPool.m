function obj = addPool(obj)
% addPool  Adds a pool to the dataPool instance
%   ADDPOOL adds an empty pool to the dataPool instance obj.
%
%   Syntax
%     obj = ADDPOOL(obj)
%
%   Description
%     obj = ADDPOOL(obj) adds an empty pool to the dataPool instance obj.
%
%   Example(s)
%     obj = FETCHDATA(obj)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%
%   Output Arguments
%
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
%   Copyright 2020 David Clemens (dclemens@geomar.de)
%

    pool                    = obj.PoolCount + 1;
    obj.DataRaw(pool)     	= {NaN(0,0)};
    obj.Data(pool)          = {NaN(0,0)};
    obj.Flag(pool)          = {zeros(0,0,'uint32')};
    obj.Uncertainty(pool)	= {sparse(zeros(0,0))};
    obj.Info(pool)          = DataKit.Metadata.info;
end