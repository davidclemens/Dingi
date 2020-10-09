function [timeseriesCollectionSlow,timeseriesCollectionRapid] = makeTimeseriesCollection(obj)
    nTimelines  = size(obj.data2TimeLink,1);
    tsc         = cell(nTimelines,1);
    for tl = 1:nTimelines
        nData           = numel(obj.data2TimeLink{tl,'data'}{:});
        tsc{tl}         = tscollection();
        tsc{tl}.Name    = obj.data2TimeLink{tl,'time'}{:};
        for d = 1:nData
            ts          = timeseries(obj.(obj.data2TimeLink{tl,'data'}{:}{d}),...
                                     obj.(['time',obj.data2TimeLink{tl,'time'}{:},'Relative']),...
                                    'Name',     obj.data2TimeLink{tl,'data'}{:}{d});
            
            ts.DataInfo.Units       = obj.data2TimeLink{tl,'units'}{:}{d};
            ts.DataInfo.UserData	= obj.data2TimeLink{tl,'subdata'}{:}{d};
            ts.TimeInfo.Units       = 'seconds';
            %ts.TimeInfo.StartDate   = datestr(obj.timeSlow(1));
            
            tsc{tl}     = addts(tsc{tl},ts(d,1));
        end
    end
    timeseriesCollectionSlow    = tsc{strcmp(obj.data2TimeLink{:,'time'},'Slow')};
    timeseriesCollectionRapid   = tsc{strcmp(obj.data2TimeLink{:,'time'},'Rapid')};
end