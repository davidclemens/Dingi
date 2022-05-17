function [path,varargout] = getToolboxRessources(toolboxName,option)
% getToolboxRessources  Return the path to the specified toolbox
%   GETTOOLBOXRESSOURCES returns the path to a toolbox and a list of all
%   ressources in that toolbox
%
%   Syntax
%     path = GETTOOLBOXRESSOURCES(toolbox)
%     path = GETTOOLBOXRESSOURCES(toolbox,option)
%     [path,files] = GETTOOLBOXRESSOURCES(__)
%
%   Description
%     path = GETTOOLBOXRESSOURCES(toolbox) returns the full path to the
%       ressources folder of toolbox 'toolbox'.
%     path = GETTOOLBOXRESSOURCES(toolbox,option) additionally specifies the
%       ressource type ('', 'parent' or 'toolbox').
%     [path,files] = GETTOOLBOXRESSOURCES(__) additionally return a struct files
%       with info on the contents of the queried toolbox.
%
%   Example(s)
%     path = GETTOOLBOXRESSOURCES('DataKit')
%     [path,files] = GETTOOLBOXRESSOURCES('AnalysisKit','toolbox')
%
%
%   Input Arguments
%     toolbox - name of the toolbox
%       char
%         The name of the toolbox to query.
%
%     option - return options
%       '' (default) | 'parent' | 'toolbox'
%         The return type. The default ('') is to return the info on the 
%         contents of the ressource folder of the queried toolbox. 'parent'
%         returns info on the contents of the parent toolbox to the queried one.
%         'toolbox' returns info on the contents of the queried toolbox.
%
%
%   Output Arguments
%     path - full path to the queried toolbox
%       char
%         Full path to the queried toolbox ressources (with option = ''), the
%         parent toolbox (with option = 'parent') or the toolbox (with option =
%         'toolbox').
%
%     files - info on the contents
%       struct
%         Struct containing info on all files in the queried toolbox (depending
%         on option).
%
%
%   Name-Value Pair Arguments
%
%
%   See also WHAT, DIR
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

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
