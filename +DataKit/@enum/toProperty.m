function value = toProperty(obj,propertyname)

    sz = size(obj);
    
    value = reshape(cat(1,obj.(propertyname)),sz);
end