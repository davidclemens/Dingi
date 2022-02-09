function obj = load(filename)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    [path,name,ext] = fileparts(filename);
    if isempty(path)
        path = pwd;
    end
    if isempty(ext)
        error('Dingi:GearKit:gearDeployment:load:missingFileExtension',...
            'Missing file extension')
    end
    
	printDebugMessage('Info','Loading ''%s'' from disk ...',[name,ext])

    s   = builtin('load',[name,ext],'-mat');
    obj = s.obj;
    
    obj.LoadFile    = fullfile(path,[name,ext]);
    obj.MatFile     = matfile(obj.LoadFile);
    
	printDebugMessage('Info','Loading ''%s'' from disk ... done',[name,ext])
end