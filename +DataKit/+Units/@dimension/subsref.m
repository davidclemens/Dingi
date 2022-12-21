function B = subsref(obj,S)

    % Subsref not allowed
    switch S(1).type
        case {'()','{}'}
            error('Dingi:DataKit:Units:dimension:subsref:invalidIndexing',...
                'A dimension instance is always scalar and can''t be indexed.')
        case '.'
            B = builtin('subsref',obj,S);
        otherwise
            error('Dingi:DataKit:Units:dimension:subsref:invalidIndexingExpression',...
                'Not a valid indexing expression.')
    end
end
