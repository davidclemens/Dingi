function addEntries(obj,name,object)
    
    import UtilityKit.Utilities.arrayhom
    
    % Homogenize inputs
    [name,object] = arrayhom(name,object);
    
    if ismember(name,obj.Keys)
        error('Dingi:DataKit:Units:unitCatalog:addEntries:DuplicateKey',...
            'The key ''%s'' already exists in the unit catalog.',name)
    end
    
    obj.Catalog = cat(1,obj.Catalog,containers.Map(name,object));
    
    % Add to base dimension list, if necessary
    isDimension = cellfun(@(o) isa(o,'DataKit.Units.dimension'),object);
    if any(isDimension)
        % Add base dimensions to list
        isBaseDimension = false(size(isDimension));
        isBaseDimension(isDimension) = cellfun(@(o) o.IsBaseDimension,object(isDimension));
        
        obj.BaseDimensions = cat(1,obj.BaseDimensions,name(isBaseDimension));
    end
end
