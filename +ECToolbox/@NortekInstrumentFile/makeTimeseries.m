function ts = makeTimeseries(obj,parameterName)
    import ECToolbox.timeseries
    
    [~,imInd]   = ismember(parameterName,cat(2,obj.data2TimeLink{:,'data'}{:}));
    nData       = cellfun(@numel,cat(2,obj.data2TimeLink{:,'data'}));
    indTimeline	= find(cumsum(nData) >= imInd,1);
    maskData    = strcmp(parameterName,obj.data2TimeLink{indTimeline,'data'}{:});
    ts          = timeseries(obj.(obj.data2TimeLink{indTimeline,'data'}{:}{maskData}),...
                             obj.(['time',obj.data2TimeLink{indTimeline,'time'}{:},'Relative']),...
                            'Name',     obj.data2TimeLink{indTimeline,'data'}{:}{maskData});

    ts.DataInfo.Units       = obj.data2TimeLink{indTimeline,'units'}{:}{maskData};
    ts.DataInfo.UserData	= obj.data2TimeLink{indTimeline,'subdata'}{:}{maskData};
    ts.TimeInfo.Units       = 'seconds';
    ts.TimeInfo.StartDate   = datestr(obj.timeSlow(1));
end