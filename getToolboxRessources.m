function [path,varargout] = getToolboxRessources(toolboxName,option)

    if exist('option','var') == 1
        if ~ischar(option)
            error('getToolboxRessources:invalidOption',...
                '''option'' has to be a valid char vector.')
        else
            option = validatestring(option,{'parent','toolbox'});
        end
    else
        option = '';
    end
    
    packageInfo     = what(toolboxName);
    switch option
        case 'parent'
            path    = packageInfo.path;
            parts   = strsplit(packageInfo.path,filesep);
            path    = [filesep,fullfile(parts{1:end - 1})];
        case 'toolbox'
            path    = packageInfo.path;
        otherwise
            path    = [packageInfo.path,'/ressources'];
    end
    files           = dir(path);
    varargout{1}    = files;
end
