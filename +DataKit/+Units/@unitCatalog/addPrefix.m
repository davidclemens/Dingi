function addPrefix(obj,name,value,symbol,alias)

    import UtilityKit.Utilities.arrayhom
    
    % Homogenize inputs
    [name,value,symbol,alias] = arrayhom(name,value,symbol,alias);
    
    % Create prefix instances
    nEntries    = numel(name);
    object      = cell(nEntries,1);
    for oo = 1:nEntries
        object{oo} = DataKit.Units.prefix(name{oo},value(oo),symbol{oo},alias{oo});
    end
    
    % Add to unitCatalog
    addEntries(obj,name,object)
end

