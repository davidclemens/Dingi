classdef quantity < double
    properties (SetAccess = immutable)
        StDev double
        Flag uint8
    end
    
    methods
        function obj = quantity(A,dA,flag)
            
            
            if nargin == 0
                A       = [];
                dA      = [];
                flag	= [];
            elseif nargin == 1
                dA      = sparse(size(A,1),size(A,2));
                flag    = zeros(size(A),'uint8');
            elseif nargin == 2
                flag    = zeros(size(A),'uint8');                
            end
            
            obj = obj@double(A);
            
            obj.StDev   = dA;
            obj.Flag    = flag;
        end
    end
    methods
        function C = disp(obj)
            [dblFmt,snglFmt] = getFloatFormats();
            
            
            formatSpecQuantity = [dblFmt,' ',char(177),' ',dblFmt,'\n'];
            
            [m,n] = size(obj);
            
            
            for row = 1:m
                
            end
            sc = sprintf(formatSpecQuantity,double(obj),obj.StDev);
            
            disp(sc)
            
            function [dblFmt,snglFmt] = getFloatFormats()
            % Display for double/single will follow 'format long/short g/e' or 'format bank'
            % from the command window. 'format long/short' (no 'g/e') is not supported
            % because it often needs to print a leading scale factor.
                switch lower(matlab.internal.display.format)
                    case {'short' 'shortg' 'shorteng'}
                        dblFmt  = '%.5g';
                        snglFmt = '%.5g';
                    case {'long' 'longg' 'longeng'}
                        dblFmt  = '%.15g';
                        snglFmt = '%.7g';
                    case 'shorte'
                        dblFmt  = '%.4e';
                        snglFmt = '%.4e';
                    case 'longe'
                        dblFmt  = '%.14e';
                        snglFmt = '%.6e';
                    case 'bank'
                        dblFmt  = '%.2f';
                        snglFmt = '%.2f';
                    otherwise % rat, hex, + fall back to shortg
                        dblFmt  = '%.5g';
                        snglFmt = '%.5g';
                end
            end
        end
    end
end
