function obj = getAxesData(obj)

    data    = cell(2,1);
    prop            = {[obj.CommonAxis(1),'Data'];...
                       [obj.IndividualAxis(1),'Data']};
	propRulerType   = {'CommonAxesRulerType';...
                       'IndividualAxesRulerType'};
	nProps  = numel(prop);
    for ii = 1:nProps
        tmpData1        = arrayfun(@(ax) get(ax.Children,prop(ii)),obj.Children,'un',0)'; % [nAxes,1] > [nObj,1] > data

        maskEmpty       = cellfun(@isempty,tmpData1);
        isNumericRuler  = obj.(propRulerType{ii}) == 'NumericRuler';
        isDatetimeRuler = obj.(propRulerType{ii}) == 'DatetimeRuler';

        % fill placeholder data
        tmpData1(maskEmpty & isNumericRuler)     = {{[0 1]}};
        tmpData1(maskEmpty & isDatetimeRuler)    = {{datetime([1,1,1;1,1,2])'}};
        maskEmpty   = cellfun(@isempty,tmpData1);
        if sum(maskEmpty) > 0
            error('not implemented yet')
        end

        tmpIndex1 	= arrayfun(@(c) repmat(c,numel(tmpData1{c}),1) ,1:numel(tmpData1),'un',0)'; % axis index
        tmpData2   	= cat(1,tmpData1{:});
        tmpIndex2  	= cat(1,tmpIndex1{:});
        tmpIndex3   = arrayfun(@(a,c) repmat(a,1,numel(tmpData2{c})) ,tmpIndex2',1:numel(tmpData2),'un',0)'; % graphic object index
        tmpData3  	= cat(2,tmpData2{:})';
        tmpIndex4   = cat(2,tmpIndex3{:})';

        data{ii}    = NaN(numel(tmpIndex4),2);
        maskIsNumeric   = ismember(tmpIndex4,find(isNumericRuler));
        maskIsDatetime	= ismember(tmpIndex4,find(isDatetimeRuler));

        try
            data{ii}(maskIsNumeric,:) 	= [tmpIndex4(maskIsNumeric),tmpData3(maskIsNumeric)];
        catch ME
            switch ME.identifier
                case 'MATLAB:datetime:cat:InvalidConcatenation'
                    if sum(maskIsNumeric) == 0

                    end
                otherwise
                    rethrow(ME);
            end
        end
    	data{ii}(maskIsDatetime,:)	= [tmpIndex4(maskIsDatetime),datenum(tmpData3(maskIsDatetime))];
    end
    obj.CommonAxesData              = data{1};
    obj.IndividualAxesData          = data{2};
end
