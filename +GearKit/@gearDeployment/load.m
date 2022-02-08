function obj = load(filename)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    [path,name,ext] = fileparts(filename);
    if isempty(path)
        path = pwd;
    end
    
	printDebugMessage('Info','Loading ''%s'' from disk ...',filename)

    s   = builtin('load',filename,'-mat');
    obj = s.obj;
    
    obj.LoadFile    = fullfile(path,[name,ext]);
    obj.MatFile     = matfile(obj.LoadFile);
    
	printDebugMessage('Info','Loading ''%s'' from disk ... done',filename)
end