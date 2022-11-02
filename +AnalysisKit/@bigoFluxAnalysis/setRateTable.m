function setRateTable(obj)

    % Create rate table
    rates = obj.createRateTablePerFit;
    
    % Set backend property
    obj.Rates_ = rates;
end
