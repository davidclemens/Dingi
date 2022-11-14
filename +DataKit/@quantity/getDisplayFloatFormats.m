function [dblFmt,snglFmt] = getDisplayFloatFormats()
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
