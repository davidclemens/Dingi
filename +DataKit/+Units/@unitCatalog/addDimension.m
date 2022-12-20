function addDimension(obj,name,parents,exponents)

    import DataKit.Units.dimension
    import UtilityKit.Utilities.arrayhom
    
    % Homogenize inputs
    [name,parents,exponents] = arrayhom(name,parents,exponents);
    
    % Create dimension instances
    nEntries    = numel(name);
    object      = cell(nEntries,1);    
    for oo = 1:nEntries
        % Raise each parent dimension to its exponent and multiply them together.
        product     = cellprod(cellfun(@(p,e) dimension(p).^e,parents{oo},num2cell(exponents{oo}),'un',0));
        
        % Create the new dimension with its value being the product from above.
        object{oo}  = dimension(name{oo},product);
    end
    
    % Add to unitCatalog
    addEntries(obj,name,object)
    
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

