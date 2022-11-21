function obj = subsasgn(obj,S,B)

    % Subsasgn not allowed
    switch S(1).type
        case {'()','{}'}
            error('Dingi:DataKit:Units:prefix:subsasgn:invalidSubscriptedAssignment',...
                'A prefix instance is always scalar and can''t be used in a subscripted assignment.')
        case '.'
            obj = builtin('subsasgn',obj,S,B);
        otherwise
            error('Dingi:DataKit:Units:prefix:subsasgn:invalidIndexingExpression',...
                'Not a valid indexing expression.')
    end
end
