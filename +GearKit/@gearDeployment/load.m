function obj = load(filename)
    
    [path,name,ext] = fileparts(filename);
    if isempty(path)
        path = pwd;
    end

    s   = builtin('load',filename,'-mat');
    obj = s.obj;
    
    obj.LoadFile    = fullfile(path,[name,ext]);
    obj.MatFile     = matfile(obj.LoadFile);
end