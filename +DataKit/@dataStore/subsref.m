function varargout = subsref(obj,S)
    switch S(1).type
        case '.'
            try
                varargout = {builtin('subsref',obj,S)};
            catch ME
                switch ME.identifier
                    case 'MATLAB:maxlhs'
                        % If a class method is called that has no return arguments (e.g
                        % obj.addDataAsNewSet(data) varargout = {builtin('subsref',obj,S)} throws an
                        % error. Try to call the methods without capturing the return values.
                     	builtin('subsref',obj,S)
                    otherwise
                        rethrow(ME)                        
                end
                
            end
        case '()'
            varargout = {builtin('subsref',obj,S)};
        case '{}'
            if length(S) == 1
                % Pattern: obj{i,...,z}, where i to z are arrays
                if numel(S.subs) == 1
                    % Pattern: obj{i}, where is is an array
                    
                    if ischar(S.subs{1}) && strcmp(S.subs{1},':')
                        % Special case obj{:}
                        setId = obj.IndexSets{:,'SetId'};
                    else
                        setId       = S.subs{1};
                    end
                    nSets       = numel(setId);
                    varargout   = cell(nSets,1);
                    for ii = 1:nSets
                        varargout{ii} = obj.getSet(setId(ii));
                    end
                else
                    % Pattern: obj{i,...,z}, where i to z are arrays 
                    varargout = {builtin('subsref',obj,S)};
                end
            elseif length(S) == 2 && strcmp(S(2).type,'()')
                % Pattern: obj{i,...,z1}(j,...,z2)
                
                if numel(S(1).subs) == 1
                    % Pattern: obj{i}(j,...,z2)
                    
                    setId = S(1).subs{1};
                    
                    if numel(S(2).subs) == 1
                        % Pattern: obj{i}(j), where i is scalar, j is an array
                        variableId = S(2).subs{1};
                        varargout{1} = obj.getSetVariable(setId,variableId);
                    elseif numel(S(2).subs) == 2
                        % Pattern: obj{i}(j,k), where i is scalar, j,k are arrays
                        
                        variableId  = S(2).subs{2};
                        rowSub      = S(2).subs{1};
                        varargout{1} = obj.getSetChunk(setId,rowSub,variableId);                        
                    else
                        error('Dingi:DataKit:dataStore:subsref:InvalidSubscript',...
                            'The index exceeds the set dimensions. A set is always 2D.')
                    end
                else
                    assert(numel(S(1).subs) == 1,...
                        'Dingi:DataKit:dataStore:subsref:NonScalarSetIndex',...
                        'If both the set ''{}'' and variable ''()'' are indexed, the set index has to be a scalar.')
                end
                    
            else
                % Use built-in for any other expression
                varargout = {builtin('subsref',obj,S)};
            end
        otherwise
        	error('Not a valid indexing expression')
    end    
end
