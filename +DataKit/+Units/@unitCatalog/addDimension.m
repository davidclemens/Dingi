function addDimension(obj,name,parents,exponents)

    import DataKit.Units.dimension
    import UtilityKit.Utilities.arrayhom
    
    % Homogenize inputs
    [name,parents,exponents] = arrayhom(name,parents,exponents);
    
    % Create dimension instances
    nEntries    = numel(name);
    for oo = 1:nEntries
        % See if parents exist in registry already.
        parentExists	= obj.Catalog.isKey(parents{oo});
        if any(~parentExists)
            % Add the parent as base dimension
            
            baseDimensions = arrayfun(@(i) dimension(parents{oo}{i}),find(~parentExists),'un',0);
            
            addEntries(obj,parents{oo}(~parentExists),baseDimensions)
        end
        
        parentDimensions  = cellfun(@(p) obj.Catalog(p),parents{oo},'un',0);
        
        
        % Raise each parent dimension to its exponent and multiply them together.
        product     = cellprod(cellfun(@(p,e) p.^e,parentDimensions,num2cell(exponents{oo}),'un',0));
        
        % Create the new dimension with its value being the product from above.
        object      = {dimension(name{oo},product)};
    
        % Add to unitCatalog
        addEntries(obj,name(oo),object)
    end
    
    function B = cellprod(A)
    % cellprod  Product of cell elements
    %   CELLPROD returns the product of the cell array elements of A. It assumes
    %   that each cell array element is a numeric scalar.
    %
        
        n = numel(A);
        
        if n == 1
            B = A{1};
        elseif n == 2
            B = A{1}.*A{2};
        elseif n > 2
            B = cellprod([{A{1}.*A{2}},A(3:end)]);
        end
    end
end

