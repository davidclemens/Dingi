classdef Debugger
% DEBUGGER Class of a debugger object
%   The DEBUGGER class holds debugging settings.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    properties
        debugLevel = categorical(2,1:4,{'Error','Warning','Info','Verbose'},'Ordinal',true); % Set debugging level
    end
    properties (Dependent)
        debugLevels % List of available debugging levels
        debugLevelsN % Number of available debugging levels
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
        %   DebugLevel - Level of debug information
        %       'Info' (default) | 'Error' | 'Warning' | 'Verbose'
        %           Sets the debug level which controls the level of information
        %           that is output to the command window.
        %
        % 
        % See also
        %
        % Copyright 2020 David Clemens (dclemens@geomar.de)
        
            % parse Name-Value pairs
            optionName          = {'DebugLevel'}; % valid options (Name)
            optionDefaultValue  = {'Info'}; % default value (Value)
            debugLevel          = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            % set debug level
            obj	= obj.setDebugLevel(debugLevel);
        end
        
        function value = get.debugLevels(obj)
            value = categories(obj.debugLevel);
        end
        
        function value = get.debugLevelsN(obj)
            value = numel(obj.debugLevels);
        end
       
        obj = setDebugLevel(obj,debugLevel)
    end
end