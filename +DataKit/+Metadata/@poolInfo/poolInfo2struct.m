function s = poolInfo2struct(obj)

    props = properties(obj);
    
    s = struct();
    for ii = 1:numel(obj)
        for pp = 1:numel(props)
            s(ii).(props{pp}) = obj(ii).(props{pp});
        end
    end
end