function varargout = colorPrint(style,format,varargin)

    import DebuggerKit.cprintf.cprintf
    
    try
        count = cprintf(style,format,varargin{:});
    catch
        count = fprintf(format,varargin{:});
    end
    if nargout == 1
        varargout{1} = count;
    else
        varargout = {};
    end
end