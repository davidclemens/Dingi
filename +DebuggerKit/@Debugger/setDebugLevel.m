function obj = setDebugLevel(obj,debugLevel)
% SETDEBUGLEVEL Sets the debug level of the debugger object.
% Sets the debugger object's debugging level.
%
% Syntax
%   Debugger = SETDEBUGLEVEL(Debugger,debugLevel)
%
% Description
%   Debugger = SETDEBUGLEVEL(Debugger,debugLevel) sets the debug level of
%       the Debugger to debugLevel and returns the Debugger object.
%
% Example(s)
%
%
% Input Arguments
%   Debugger - Debugger object
%           The Debugger object of which the level should be set.
%
%   debugLevel - Level of debug information
%       'Info' (default) | 'Error' | 'Warning' | 'Verbose'
%           Sets the debug level which controls the level of information
%           that is output to the command window.
%
%
% Name-Value Pair Arguments
%
%
% See also
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    [im,imInd]       = ismember(debugLevel,obj.debugLevels);
    if ~im
        error('Dingi:DebuggerKit:Debugger:setDebugLevel:invalidDebugLevel',...
          '''%s'' is not a valid debug level.\n\tValid levels are: %s.',strjoin(obj.debugLevels,', '))
    end

    obj.debugLevel  = categorical(imInd,1:obj.debugLevelsN,obj.debugLevels,'Ordinal',true);

%     if obj.debugLevel >= 'Info'
%         fprintf('INFO: Debug Level is set to ''%s''\n',obj.debugLevel);
%     end
end
