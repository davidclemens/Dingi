function filenames = save(objIn,folder,varargin)
    
    import DebuggerKit.Debugger.printDebugMessage

    [path,~,ext] = fileparts(folder);
    if isempty(path)
        path = pwd;
    end
    
    nGearDeployments    = numel(objIn);
    gearDeploymentExt   = objIn(1).gearType.FileExtension;
    if ~strcmp(ext,gearDeploymentExt)
        printDebugMessage('Dingi:GearKit:gearDeployment:save:invalidFileExtension',...
            'Warning','The provided file extension ''%s'' was changed to ''%s''',ext,gearDeploymentExt);
        ext = gearDeploymentExt;
    end
    
    filenames = fullfile(path,strcat({objIn.gearId}',ext));
    
    for ii = 1:nGearDeployments
        printDebugMessage('Info','Saving ''%s'' to disk ...',filenames{ii})
        
        obj = objIn(ii);
        obj.SaveFile    = filenames{ii};
        obj.MatFile     = matfile(filenames{ii});
        builtin('save',filenames{ii},'obj','-v7.3');
        
        printDebugMessage('Info','Saving ''%s'' to disk ... done',filenames{ii})
    end
end
