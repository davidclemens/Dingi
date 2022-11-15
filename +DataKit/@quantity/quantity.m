classdef quantity < double
    properties (SetAccess = immutable)
        Sigma double
        Flag DataKit.bitflag
    end
    
    methods
        function obj = quantity(A,sigma,flag,varargin)
            
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
            elseif nargin == 1
                sigma  	= sparse(size(A,1),size(A,2));
                flag    = DataKit.bitflag(flagEnumerationClass,size(A,1),size(A,2));
            elseif nargin == 2
                flag    = DataKit.bitflag(flagEnumerationClass,size(A,1),size(A,2));
            end
            
            validateattributes(A,{'numeric'},{},mfilename,'A',1)
            validateattributes(sigma,{'numeric'},{'size',size(A)},mfilename,'sigma',2)
            validateattributes(flag,{'DataKit.bitflag'},{'size',size(A)},mfilename,'flag',3)
            
            obj = obj@double(A);
            
            obj.Sigma   = sigma;
            obj.Flag    = flag;
        end
    end
    methods
        C = char(obj)
        disp(obj,varargin)
        varargout = subsref(obj,S)
        obj = subsasgn(obj,S,varargin)
    end
    methods (Static)
        [dblFmt,snglFmt] = getDisplayFloatFormats()
    end
end
