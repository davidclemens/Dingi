classdef Debugger < handle
% DEBUGGER Class of a debugger object
%   The DEBUGGER class holds debugging settings.
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    properties
        Level DebuggerKit.debugLevel = DebuggerKit.debugLevel.Info % Set debugging level
        ShowTime logical = false
        UseColors logical = true
        ShowStack logical = false
        TruncateMultiline logical = true
    end
    properties (Dependent)
        Levels DebuggerKit.debugLevel
    end
    methods
        function obj = Debugger(varargin)
        % DEBUGGER Constructs a debugger object.
        % Create a DEBUGGER object that holds debugging settings.
        %
        % Syntax
        %   Debugger = DEBUGGER()
        %   Debugger = DEBUGGER(__,Name,Value)
        %
        % Description
        %   Debugger = DEBUGGER() creates a DEBUGGER object with default 
        %       values.
        %
        %   Debugger = DEBUGGER(__,Name,Value) specifies additional 
        %       parameters for the DEBUGGER using one or more 
        %       name-value pair arguments as listed below.
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %
        %
        % Name-Value Pair Arguments
        %   Level - Level of debug information
        %       'Info' (default) | 'Error' | 'Warning' | 'Verbose'
        %           Sets the debug level which controls the level of information
        %           that is output to the command window.
        %
        %   UseColors - Determine if the output should be colored
        %       true (default) | false
        %           Determines if the command line output should be colorized.
        %
        %   ShowTime - Show/hide timestamp
        %       false (default) | true
        %           Set if each debug message should show the timestamp or not.
        %
        %   ShowStack - Show/hide call stack
        %       false (default) | true
        %           Set if each debug message should show the call stack or not.
        %
        %   TruncateMultiline - Truncate multiline messages
        %       true (default) | false
        %           Set if each debug message should be truncated if it contains
        %           multiple lines.
        %
        % 
        % See also
        %
        % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
        
            import internal.stats.parseArgs
            
            % parse Name-Value pairs
            optionName          = {'Level','UseColors','ShowTime','ShowStack','TruncateMultiline'}; % valid options (Name)
            optionDefaultValue  = {'Info',true,false,false,true}; % default value (Value)
            [debugLevel,...
             useColors,...
             showTime,...
             showStack,...
             truncateMultiline]  = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            % Set debug level
            obj.Level = debugLevel;
            obj.UseColors = useColors;
            obj.ShowTime = showTime;
            obj.ShowStack = showStack;
            obj.TruncateMultiline = truncateMultiline;
        end
    end
    
    methods (Static)
        printDebugMessage(varargin)
        varargout = colorPrint(style,format,varargin)
    end
    
    % Get methods
    methods
        function value = get.Levels(obj)            
            value = enumeration(obj.Level);
        end
    end
end