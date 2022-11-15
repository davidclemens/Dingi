function [dblFmt,snglFmt] = getDisplayFloatFormats()
% getDisplayFloatFormats  Get current float display format setting
%   GETDISPLAYFLOATFORMATS get the currently active float value display format.
%
%   Syntax
%     dblFmt = GETDISPLAYFLOATFORMATS()
%     [dblFmt,snglFmt] = GETDISPLAYFLOATFORMATS()
%
%   Description
%     dblFmt = GETDISPLAYFLOATFORMATS()  Return the current display format for
%       double-precision values.
%     [dblFmt,snglFmt] = GETDISPLAYFLOATFORMATS()  Additionally return the
%       current display format for single-precision values.
%
%   Example(s)
%     [dblFmt,snglFmt] = GETDISPLAYFLOATFORMATS()  dblFmt = '%.5g' & 
%       snglFmt = '%.5g'.
%
%
%   Input Arguments
%
%
%   Output Arguments
%     dblFmt - Double display format
%       char row vector
%         The double-precision format specifier set for the command window. This
%         follows the 'format style' syntax for setting the command window
%         output display format.
%
%     snglFmt - Single display format
%       char row vector
%         The single-precision format specifier set for the command window. This
%         follows the 'format style' syntax for setting the command window
%         output display format.
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

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
