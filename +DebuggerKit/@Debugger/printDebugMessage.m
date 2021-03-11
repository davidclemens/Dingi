function printDebugMessage(varargin)
    
    import DebuggerKit.Debugger.printDebugMessage
    import DebuggerKit.debugLevel.validate
    
    global DEBUGGER
    
    % If no global debugger instance is defined yet. Define it now.
    if isempty(DEBUGGER)
        DEBUGGER = DebuggerKit.Debugger;
    end
    
    % Parse input
    if nargin < 2
        printDebugMessage('Dingi:DebuggerKit:Debugger:printDebugMessage:minimumInputs',...
            'FatalError','Not enough input arguments')
    else
        if isempty(regexp(varargin{1},'^([^:]+:)+[^:]+$','once'))
            messageId = '';
            messageLevel = varargin{1};
            message = varargin{2};
            varargin = varargin(3:end);
        else
            messageId = varargin{1};
            messageLevel = varargin{2};
            message = varargin{3};
            varargin = varargin(4:end);
        end
    end
    
    % Print the debug message to the command line
    if DEBUGGER.Level >= messageLevel
        printLevel(messageLevel)
        printTime(DEBUGGER)
        printMessage(DEBUGGER,message,varargin{:})
        printStack(DEBUGGER)
        fprintf('\n');
    end
    
    % Stop execution if fatel error occurs
    if messageLevel == DebuggerKit.debugLevel.FatalError
        stopExecution()
    end
end

function printLevel(messageLevel)
    
    if isnumeric(messageLevel)
        msgLevel = DebuggerKit.debugLevel.fromProperty('Id',messageLevel);
    elseif ischar(messageLevel)
        msgLevel = DebuggerKit.debugLevel.(messageLevel);
    end
    DebuggerKit.Debugger.colorPrint(['*',msgLevel.Color],[msgLevel.Name,'​']) % There is a zero-width space at the end to fix formatting
end

function printTime(db)
    
    if db.ShowTime
        DebuggerKit.Debugger.colorPrint('[0.6,0.6,0.6]',[' ',datestr(datetime('now'),30)])
    end
end

function printMessage(db,message,varargin)
    
    messageRendered = sprintf(message,varargin{:});
    if db.TruncateMultiline
        newlinePosition = regexp(messageRendered,newline,'once');
        if ~isempty(newlinePosition)
            messageRendered = [messageRendered(1:newlinePosition - 1),' [...]'];
        end
    end
    DebuggerKit.Debugger.colorPrint('[0.000,0.000,0.000]',[': ',messageRendered]);
end

function printStack(db)
    
    stack = dbstack(2,'-completenames');
    if db.ShowStack && ~isempty(stack)
        stackNames      = {stack.name}';
        stackLines      = strtrim(cellstr(num2str(cat(1,stack.line),'%u')));
        stackURLs       = strcat({'matlab: opentoline('''},{stack.file}',{''','},stackLines,{',0)'});
        stackLineStr    = cellfun(@(u,l) makeLink(l,u),stackURLs,stackLines,'un',0);
        
        stackStr    = strcat(stackNames,{'@'},stackLineStr);
        DebuggerKit.Debugger.colorPrint('[0.6,0.6,0.6]',[' [',strjoin(flipud(stackStr),':'),']'])
    end
end

function str = makeLink(txt,URL)
    str = ['<a href="',URL,'">',txt,'</a>'];
end

function stopExecution()
% Stop execution without throwing an error
    ms.message        = '';
    ms.stack          = dbstack('-completenames');
    ms.stack(1:end)   = [];

    ds    = dbstatus();
    stoponerror	= any(strcmp('error', {ds.cond}));

    setappdata(0, 'dberrorkeep', stoponerror);

    dbclear error

    error(ms);
end