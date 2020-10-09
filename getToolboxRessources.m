function [path,varargout] = getToolboxRessources(toolboxName)
    packageInfo     = what(toolboxName);
    path            = [packageInfo.path,'/ressources'];
    files           = dir(path);
    
    varargout{1}    = files;
end