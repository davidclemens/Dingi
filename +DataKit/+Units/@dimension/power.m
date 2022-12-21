function C = power(obj,B)

    import DataKit.Units.dimension
    
    validateattributes(B,{'numeric'},{'scalar','real','finite'},mfilename,'B',2)
    
    % Shortcut to unity
    if B == 0
        C = 1;
        return
    end
    
    C = dimension(['(',obj.Name,')^',num2str(B)],obj.Value.^B);
end
