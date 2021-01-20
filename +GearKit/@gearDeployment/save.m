function filenames = save(obj,filename,varargin)

    [path,~,ext] = fileparts(filename);
    if isempty(path)
        path = pwd;
    end
    
    nGearDeployments    = numel(obj);
    gearDeploymentExt   = obj(1).validFileExtensions{strcmp(obj(1).gearType,obj(1).validGearTypes)};
    if ~strcmp(ext,gearDeploymentExt)
        warning('GearKit:gearDeployment:save:invalidFileExtension',...
            'The provided file extension ''%s'' was changed to ''%s''',ext,gearDeploymentExt);
        ext = gearDeploymentExt;
    end
    
    filenames = fullfile(path,strcat({obj.gearId}',ext));
    
    for ii = 1:nGearDeployments
        varSave = obj(ii);
        builtin('save',filenames{ii},'varSave','-v7.3');
    end
end