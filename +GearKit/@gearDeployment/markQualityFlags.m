function varargout = markQualityFlags(obj)
% MARKQUALITYFLAGS

    import UIKit.GearDeploymentDataFlagger.dataFlagger
    
    df  = dataFlagger(obj);
    
    if nargout == 1
        varargout{1} = df;
    end
end