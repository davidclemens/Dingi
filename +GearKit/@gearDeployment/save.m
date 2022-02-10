function filenames = save(objIn,varargin)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    narginchk(1,2)
    
    if nargin == 1
        folder = {objIn.LoadFile}';
    elseif nargin == 2
        folder = varargin{1};
    end
    
    if ischar(folder)
        folder = {folder};
    end
    
    [folder,~,~]    = cellfun(@fileparts,folder,'un',0);
    isEmptyFolder   = cellfun(@isempty,folder);
    if any(isEmptyFolder)
        folderForEmptyFolders = uigetdir;
        folder(isEmptyFolder) = {folderForEmptyFolders};
    end
    
    nGearDeployments    = numel(objIn);
    gearDeploymentExt   = objIn(1).gearType.FileExtension;
    filenames           = fullfile(folder,strcat({objIn.gearId}',gearDeploymentExt));
    
    for ii = 1:nGearDeployments
        printDebugMessage('Info','Saving ''%s'' to disk ...',filenames{ii})
        
        obj             = objIn(ii);
        obj.SaveFile    = filenames{ii};
        builtin('save',filenames{ii},'obj','-v7.3');
        
        printDebugMessage('Info','Saving ''%s'' to disk ... done',filenames{ii})
    end
end
