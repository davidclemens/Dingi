function tbl = info2table(obj)

    if numel(obj) == 1
        tbl     = table(...
                    (1:obj.VariableCount)',...
                    obj.Variable',...
                    obj.VariableId',...
                    cellstr(obj.VariableType)',...
                    obj.VariableUnit',...
                    obj.VariableDescription',...
                    obj.VariableOrigin',...
                    obj.VariableFactor',...
                    obj.VariableOffset',...
                    obj.VariableMeasuringDevice',...
                    'VariableNames',{'VariableIndex','Variable','Id','Type','Unit','Description','Origin','Factor','Offset','MeasuringDevice'});
    else
        error('Dingi:DataKit:Metadata:info:info2table:invalidShape',...
          'Only works in a scalar context')
    end
end