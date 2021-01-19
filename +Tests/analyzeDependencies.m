function [funcList, toolList] = analyzeDependencies()
    
    toolboxInfo = what('toolboxes');
    toolboxPath = toolboxInfo.path;
    
    mFiles      = struct2table(dir(fullfile(toolboxPath, '**', '*.m')));
    mFiles.path = fullfile(mFiles{:,'folder'},mFiles{:,'name'});
    
    isTrial     = regexp(mFiles{:,'name'},'.+\.trial\.m$');
    isTrial     = ~cellfun(@isempty,isTrial);
    
    isGitignore     = regexp(mFiles{:,'folder'},'/gitignore');
    isGitignore     = ~cellfun(@isempty,isGitignore);
    
    mFiles  = mFiles(~isTrial & ~isGitignore,:);
    
    [funcList,toolList] = matlab.codetools.requiredFilesAndProducts(mFiles{:,'path'});
    funcList            = funcList';
    toolList            = toolList';
end