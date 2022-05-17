function setDebugLevel(level)
% setDebugLevel  Sets the debug level
%   SETDEBUGLEVEL Sets the debug level of the current debugger instance or
%     creates a new instance with that debug level.
%
%   Syntax
%     SETDEBUGLEVEL(level)
%
%   Description
%     SETDEBUGLEVEL(level) sets the debug level to level
%
%   Example(s)
%     SETDEBUGLEVEL('Verbose')
%     SETDEBUGLEVEL('v')
%     SETDEBUGLEVEL('err')
%     SETDEBUGLEVEL('e')
%     SETDEBUGLEVEL('Error')
%
%
%   Input Arguments
%     level - debug level
%       char
%         The name of the debug level. It must be an unambiguous reference
%         to the available debug levels.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also Debugger
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    import DebuggerKit.Debugger.printDebugMessage
    
    global DEBUGGER
    
    % If no global debugger instance is defined yet. Define it now.
    if isempty(DEBUGGER)
        DebuggerKit.Debugger(...
            'Level',        level);
        
        newLevel = char(DEBUGGER.Level);
        
        printDebugMessage('Dingi:DebuggerKit:Debugger:setDebugLevel:newLevel',...
            'Info','Debug level is set to ''%s''.',newLevel)
    else
        oldLevel = char(DEBUGGER.Level);
        
        DEBUGGER.Level = level;
        
        newLevel = char(DEBUGGER.Level);
        
        printDebugMessage('Dingi:DebuggerKit:Debugger:setDebugLevel:newLevel',...
            'Info','Debug level is set to ''%s''. Was ''%s''.',newLevel,oldLevel)
    end
    
end