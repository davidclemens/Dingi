function [time,data,meta] = initializeGetDataOutputs()
% INITIALIZEGETDATAOUTPUTS

    time = cell.empty;
    data = cell.empty;
    meta	= struct('dataSourceType',      categorical(NaN),...
                     'dataSourceId',        categorical(NaN),...
                     'dataSourceDomain',    categorical(NaN),...
                     'mountingLocation',    [],...
                     'dependantVariables',  {''},...
                     'name',                {''},...
                     'unit',                {''},...
                     'parameterId',         uint16.empty);
    meta = meta(false(size(meta)));
end