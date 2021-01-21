function version = getToolboxVersion()
    
    toolboxInfo = what('toolboxes');
    
    fId     = fopen([toolboxInfo.path,'/.version'],'r');
    raw     = textscan(fId,'%s',1);
    fclose(fId);
    
    version = raw{1}{1};
end