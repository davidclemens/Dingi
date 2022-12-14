function out = eval(obj,tokenFunc,binaryOperators,unaryOperators)

    if ~isempty(obj.Right)
        % Binary or implicit operator
        if ~isempty(obj.Operator)
            opText = obj.Operator.Text;
        else
            opText = '';
        end
        
        if ~ismember(opText,binaryOperators.keys)
            error('Missing binary operator')
        end
        
        a = obj.Left.eval(tokenFunc,binaryOperators,unaryOperators);
        b = obj.Right.eval(tokenFunc,binaryOperators,unaryOperators);
        
        opFunc = binaryOperators(opText);
        % TODO: If a or b are non numeric, their char value is used for computation.
        % E.g. 3*'x' gives 3*120. However, it should return a function handle h with
        % h = @(x) 3*x, or something similar.
        
        if obj.Left.dependsOnName
            if isa(a,'function_handle')
                aFunc = a;
            else
                aFunc = str2func(['@(',a,') ',a]);
            end
            [aInputs,aFuncStr] = parseFunctionHandle(aFunc);
        else
            aInputs = {};
            
            % TODO: Precision is lost here, as numeric values are converted to char
            aFuncStr = num2str(a);
        end
        if obj.Right.dependsOnName
            if isa(b,'function_handle')
                bFunc = b;
            else
                bFunc = str2func(['@(',b,') ',b]);
            end
            [bInputs,bFuncStr] = parseFunctionHandle(bFunc);
        else
            bInputs = {};
            
            % TODO: Precision is lost here, as numeric values are converted to char
            bFuncStr = num2str(b);
        end
        
        if obj.Left.dependsOnName || obj.Right.dependsOnName
            out = str2func(['@(',strjoin([aInputs,bInputs],','),')',aFuncStr,opText,bFuncStr]);
        else
            out = opFunc(a,b);
        end
        
    elseif ~isempty(obj.Operator)
        % Unary operator
        opText = obj.Operator.Text;
        if ~ismember(opText,unaryOperators.keys)
            error('Missing unary operator')
        end
        
        opFunc = unaryOperators(opText);
        
        a = obj.Left.eval(tokenFunc,binaryOperators,unaryOperators);
        % TODO: If a or b are non numeric, their char value is used for computation.
        % E.g. -'x' gives -120. However, it should return a function handle h with
        % h = @(x) -x, or something similar.
        
        if obj.Left.dependsOnName
            if isa(a,'function_handle')
                aFunc = a;
            else
                aFunc = str2func(['@(',a,') ',a]);
            end
            [aInputs,aFuncStr] = parseFunctionHandle(aFunc);
        else
            aInputs = {};
            
            % TODO: Precision is lost here, as numeric values are converted to char
            aFuncStr = num2str(a);
        end
        
        if obj.Left.dependsOnName
            out = str2func(['@(',strjoin(aInputs,','),')',opText,aFuncStr]);
        else
            out = opFunc(a);
        end
    else
        % Single value
        
        out = tokenFunc(obj.Left);
    end
    
    function [inputs,funcStr] = parseFunctionHandle(func)
        
        funcChar    = func2str(func);
        inputs      = strsplit(regexp(funcChar,'(?<=^@\()[^\)]*','match','once'),',');
        funcStr     = regexp(funcChar,'^@\(.*\)\s*(.*)$','tokens');
        funcStr     = funcStr{1}{1};
    end
end
