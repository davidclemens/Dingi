function L = getSubclasses(ofClass,withinScope)
    
    global classes
    classes = struct('Class',char.empty,'Path',char.empty,'Superclasses',cell.empty);
    
    listClasses(withinScope);

    maskClasses = cellfun(@(cl) ismember({ofClass},cl),cat(1,classes.Superclasses));
    L           = classes(maskClasses);
    L           = L(:);
    
    function subpaths = listClasses(path)
        
        excludePath = '/Dingi/Tests/';
        classesNew  = struct('Class',{''},'Path',{''},'Superclass',{''});
        if ischar(path)
            path = cellstr(path);
        end        
        nPath       = numel(path);
        for pp = 1:nPath
            tmp         = what(path{pp});

            subpaths    = fullfile(tmp.path,tmp.packages);
            pathMask    = cellfun(@isempty,regexp(subpaths,'/Dingi/Tests'));
            subpaths    = subpaths(pathMask);

            if ~isempty(tmp.classes)
                classNames	= strsplit(tmp.path,'+');
                classNames  = strrep(classNames,'/','');
                classNames	= strcat(strjoin(classNames(2:end),'.'),{'.'},tmp.classes);
                nClasses    = numel(classNames);
                ind             = numel(classes) + 1:numel(classes) + nClasses;
                superClassList  = cell(nClasses,1);
                for cc = 1:nClasses
                    a                   = eval(['?',classNames{cc}]);
                    superClassList{cc}  = arrayfun(@(cl) cl.Name, a.SuperclassList,'un',0);
                end
                superClassList(cellfun(@isempty,superClassList)) = {{''}};
                
                classes(ind)    = struct('Class',classNames,'Path',repmat({tmp.path},nClasses,1),'Superclasses',superClassList);
            end
            
            if ~isempty(subpaths)
                subpaths = listClasses(subpaths);
            end
        end
    end
end