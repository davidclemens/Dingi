function obj = str2variable(str)

	if ~(iscellstr(str) || ischar(str))
        error('Dingi:DataKit:Metadata:variable:str2Variable:invalidDataType',...
            'The input argument ''str'' has to be a cellstr or character array.')
	end

    if iscellstr(str)
        obj     = cellfun(@(s) DataKit.Metadata.variable(s),str,'un',0);
        obj     = cat(1,obj{:});
    else
        obj     = DataKit.Metadata.variable(str);
    end
end