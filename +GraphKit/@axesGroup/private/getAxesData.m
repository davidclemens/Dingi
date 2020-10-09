function obj = getAxesData(obj)
    
    data    = cell(2,1);
    prop   	= {[obj.CommonAxis(1),'Data'];...
               [obj.IndividualAxis(1),'Data']};
	nProps  = numel(prop);
	axisIsDatatime = false(nProps,1); % init
    for ii = 1:nProps
        tmpData1  	= arrayfun(@(ax) get(ax.Children,prop(ii)),obj.Children,'un',0);
        tmpIndex1 	= arrayfun(@(c) repmat(c,numel(tmpData1{c}),1) ,1:numel(tmpData1),'un',0);
        tmpData2   	= cat(1,tmpData1{:});
        tmpIndex2  	= cat(1,tmpIndex1{:});
        tmpIndex3   = arrayfun(@(c) repmat(c,1,numel(tmpData2{c})) ,1:numel(tmpData2),'un',0);
        tmpData3  	= cat(2,tmpData2{:})';
        tmpIndex4   = cat(2,tmpIndex3{:})';
        
        axisIsDatatime(ii) = isdatetime(tmpData3);
        if isdatetime(tmpData3)
            data{ii}	= [tmpIndex2(tmpIndex4),datenum(tmpData3)];
        else
            data{ii}	= [tmpIndex2(tmpIndex4),tmpData3];
        end

    end
    obj.CommonAxesData              = data{1};
    obj.IndividualAxesData          = data{2};
    obj.CommonAxesIsDatetime        = axisIsDatatime(1);
    obj.IndividualAxesIsDatetime	= axisIsDatatime(2);
end