function C = char(obj)
    
    if numel(obj) > 1
        error('Dingi:GearKit:measuringDevice:char:nonScalarContext',...
            'Only works in a scalar context.')
    elseif isempty(obj)
        C = char();
        return
    end
    
    C = cellstr(obj);
    C = C{:};
end