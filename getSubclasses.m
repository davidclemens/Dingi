function L = getSubclasses(ofClass,withinScope)
% getSubclasses  List subclasses of a class
%   GETSUBCLASSES lists all subclasses of a class.
%
%   Syntax
%     L = GETSUBCLASSES(ofClass,withinScope)
%
%   Description
%     L = GETSUBCLASSES(ofClass,withinScope) lists all subclasses of class
%       ofClass limiting the search to the folder 'withinScope' and its
%       subfolders.
%
%   Example(s)
%     L = GETSUBCLASSES('GearKit.gearDeployment','~/Toolboxes/Dingi')
%
%
%   Input Arguments
%     ofClass - superclass name
%       char
%         Superclass name in dot notation (e.g. '<PackageName>.<ClassName>').
%
%     withinScope - folder to limit search to
%       char
%         Limits the search for subclasses to folder 'withinScope' and all
%         subfolders.
%
%
%   Output Arguments
%     L - list of subclasses
%       struct
%         Struct listing all subclasses with fields class name 'Class', full
%         path 'Path' and superclass name 'Superclasses'.
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    global classes
    classes = struct('Class',char.empty,'Path',char.empty,'Superclasses',cell.empty);
    
    narginchk(2,2)
    
    % Check that the scope is a valid folder
    if exist(withinScope,'dir') ~= 7
        error('Dingi:getSubclasses:invalidScope',...
            '''%s'' is not a valid folder.',withinScope)
    end
    
    listClasses(withinScope);

    maskClasses = cellfun(@(cl) ismember({ofClass},cl),cat(1,classes.Superclasses));
    L           = classes(maskClasses);
    L           = L(:);
    
    function subpaths = listClasses(path)
        
        if ischar(path)
            path = cellstr(path);
        end        
        nPath       = numel(path);
        for pp = 1:nPath
            tmp           	= what(path{pp});
            
            pathHasPackages	= ~isempty(tmp.packages);
            pathHasClasses	= ~isempty(tmp.classes);

            if pathHasClasses
                classNames	= strsplit(tmp.path,'+');
                classNames  = strrep(classNames,'/','');
                classNames	= strcat(strjoin(classNames(2:end),'.'),{'.'},tmp.classes);
                nClasses    = numel(classNames);
                ind             = numel(classes) + 1:numel(classes) + nClasses;
                superClassList  = cell(nClasses,1);
                for cc = 1:nClasses
                    a                   = eval(['?',classNames{cc}]);
                    if isempty(a)
                        % The class folder exists, but no classdef .m file is found.
                        continue
                    end
                    superClassList{cc}  = arrayfun(@(cl) cl.Name, a.SuperclassList,'un',0);
                end
                superClassList(cellfun(@isempty,superClassList)) = {{''}};
                
                classes(ind)    = struct('Class',classNames,'Path',repmat({tmp.path},nClasses,1),'Superclasses',superClassList);
            end
            
            
            if pathHasPackages                
                subpaths    = fullfile(tmp.path,strcat({'+'},tmp.packages));
                pathMask    = cellfun(@isempty,regexp(subpaths,'/Dingi/\+Tests'));
                subpaths    = subpaths(pathMask);
                
                subpaths    = listClasses(subpaths);
            else
                subpaths    = {''};
            end
        end
    end
end
