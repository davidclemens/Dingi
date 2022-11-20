classdef quantity < double
    properties (SetAccess = immutable)
        Sigma double % Uncertainty
        Flag DataKit.bitflag % Flags
        Unit % Unit
    end
    
    methods
        function obj = quantity(A,sigma,flag,unit,varargin)
        % quantity  Create a quantity array
        %   QUANTITY creates a quantity array.
        %
        %   Syntax
        %     obj = QUANTITY(A)
        %     obj = QUANTITY(A,sigma)
        %     obj = QUANTITY(A,sigma,flag)
        %     obj = QUANTITY(A,sigma,flag,unit)
        %     obj = QUANTITY(__,Name,Value)
        %
        %   Description
        %     obj = QUANTITY(A)  Convert the values in A to quantities with no
        %       uncertainty and no flags.
        %     obj = QUANTITY(A,sigma)  Additionally specify the uncertainty as
        %       standard deviation.
        %     obj = QUANTITY(A,sigma,flag)  Additionally specify the flag(s).
        %     obj = QUANTITY(A,sigma,flag,unit)  Additionally specify the unit.
        %     obj = QUANTITY(__,Name,Value)  Add additional options
        %       specified by one or more Name,Value pair arguments. You can include any
        %       of the input arguments in previous syntaxes.
        %
        %   Example(s)
        %     obj = QUANTITY(5)  returns 5 ± 0
        %     obj = QUANTITY(5,0.1)  returns 5 ± 0.1
        %     obj = QUANTITY(5,0.1,2)  returns 5 ± 0.1 1⚑
        %
        %
        %   Input Arguments
        %     A - Value
        %       numeric array
        %         The input values to be converted to a quantity array of the same
        %         shape.
        %
        %     sigma - Uncertainty
        %       numeric array
        %         The value's uncertainty, specified as standard deviation in the form
        %         of a numeric array with the same shape as A.
        %
        %     flag - Flags
        %       DataKit.bitflag array | numeric array
        %         The values flag(s), specified as a bitflag array or a numeric array
        %         that can be converted to a bitflag with the same shape as A.
        %
        %
        %   Output Arguments
        %     obj - Quantity
        %       DataKit.quantity array
        %         Output quantity specified as a DataKit.quantity array.
        %
        %
        %   Name-Value Pair Arguments
        %     FlagEnumerationClass - Flag enumeration class name
        %       'DataKit.Metadata.validators.validFlag' (default) | char
        %         The enumeration class to be used for the bitflag. See the
        %         DataKit.bitflag documentation for details.
        %
        %
        %   See also DataKit.bitflag
        %
        %   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
        %
            
            import internal.stats.parseArgs
            
            % Parse Name-Value pairs
            optionName          = {'FlagEnumerationClass'}; % valid options (Name)
            optionDefaultValue  = {'DataKit.Metadata.validators.validFlag'}; % default value (Value)
            [flagEnumerationClass ...
                ] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
         
            if nargin == 0
                A       = [];
                sigma  	= [];
                flag	= DataKit.bitflag(flagEnumerationClass);
                unit    = [];
            elseif nargin == 1
                sigma  	= sparse(size(A,1),size(A,2));
                flag    = DataKit.bitflag(flagEnumerationClass,size(A,1),size(A,2));
                unit    = [];
            elseif nargin == 2
                flag    = DataKit.bitflag(flagEnumerationClass,size(A,1),size(A,2));
                unit    = [];
            elseif nargin == 3
                if isa(flag,'DataKit.bitflag')
                    % Ok
                elseif isnumeric(flag)
                    % Try to convert numeric input to a bitflag
                    flag = DataKit.bitflag(flagEnumerationClass,flag);
                else
                    % Is handled in the validation below
                end
                unit    = [];
            elseif nargin == 4
                % TODO: process unit input by user
            end
            
            validateattributes(A,{'numeric'},{},mfilename,'A',1)
            validateattributes(sigma,{'numeric'},{'size',size(A)},mfilename,'sigma',2)
            validateattributes(flag,{'DataKit.bitflag'},{'size',size(A)},mfilename,'flag',3)
            
            % Call superclass constructor
            obj = obj@double(A);
            
            % Assign property values
            obj.Sigma   = sigma;
            obj.Flag    = flag;
            obj.Unit    = unit;
        end
    end
    methods
        C = char(obj)
        disp(obj,varargin)
        varargout = subsref(obj,S)
        obj = subsasgn(obj,S,varargin)
    end
    
    % Arithmetic
    methods
        obj = plus(A,B)
        obj = minus(A,B)
        obj = times(A,B)
        obj = rdivide(A,B)
    end
    
    methods (Static)
        [dblFmt,snglFmt] = getDisplayFloatFormats()
    end
end
