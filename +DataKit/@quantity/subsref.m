function varargout = subsref(obj,S)
    switch S(1).type
        case '()'
            [varargout{1:nargout}] = DataKit.quantity(...
                subsref(double(obj),S(1)),...
                subsref(obj.StDev,S(1)),...
                subsref(obj.Flag,S(1)));
        otherwise
            [varargout{1:nargout}] = subsref@double(obj,S);
    end
end
