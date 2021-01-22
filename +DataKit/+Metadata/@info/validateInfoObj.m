function obj = validateInfoObj(obj)

    if obj.NoIndependantVariable && obj.VariableCount > 1
        error('Dingi:DataKit:Metadata:info:missingIndependantVariable',...
            'An independant variable is missing.')
    end
end