function filenames = save(objIn,filename,varargin)

    [path,~,ext] = fileparts(filename);
    if isempty(path)
        path = pwd;
    end
    
    nGearDeployments    = numel(objIn);
    gearDeploymentExt   = objIn(1).gearType.FileExtension;
    if ~strcmp(ext,gearDeploymentExt)
        warning('Dingi:GearKit:gearDeployment:save:invalidFileExtension',...
            'The provided file extension ''%s'' was changed to ''%s''',ext,gearDeploymentExt);
        ext = gearDeploymentExt;
    end
    
    filenames = fullfile(path,strcat({objIn.gearId}',ext));
    
    for ii = 1:nGearDeployments
        obj = objIn(ii);
        obj.SaveFile    = filenames{ii};
        obj.MatFile     = matfile(filenames{ii});
        builtin('save',filenames{ii},'obj','-v7.3');
    end
end
