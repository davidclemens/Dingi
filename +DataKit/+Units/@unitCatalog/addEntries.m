function addEntries(obj,name,object)

    nargoutchk(0,1)
    
    if ismember(name,obj.Keys)
        error('Dingi:DataKit:Units:unitCatalog:addEntries:DuplicateKey',...
            'The key ''%s'' already exists in the unit catalog.',name)
    end
    
    obj.Catalog = cat(1,obj.Catalog,containers.Map(name,object));
end
