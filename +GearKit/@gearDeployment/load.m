function obj = load(varargin)
    
    import DebuggerKit.Debugger.printDebugMessage
    
    narginchk(0,1)
    
    if nargin == 0
        filename = '';
    elseif nargin == 1
        filename = varargin{1};
    end
    
    if ischar(filename)
        filename = {filename};
    end
    filename    = filename(:);
    
	[path,name,ext] = cellfun(@fileparts,filename,'un',0);
    if any(cat(2,cellfun(@isempty,path), cellfun(@isempty,name), cellfun(@isempty,ext)),2)
        [name,path] = uigetfile(...
            {'*.bigo;*.ec',     'gearDeployment Files (*.bigo;*.ec)'},...
            'Pick file(s) to load...',...
            'MultiSelect', 'on');
        if ischar(path)
            path = {path};
        end
        if ischar(name)
            name = {name};
        end
        [path,name,ext] = cellfun(@fileparts,strcat(path(:),name(:)),'un',0);
    end
    
    if numel(unique(ext)) > 1
        error('Dingi:GearKit:gearDeployment:load:onlyFilesOfSameSubclassAreLoadable',...
            'Only multiple files of the same gearDeployment subclass can be loaded at the same time.')
    end
    
    nGearDeployments = numel(name);
    for gd = 1:nGearDeployments
        printDebugMessage('Info','Loading ''%s'' from disk ...',[name{gd},ext{gd}])

        s           = builtin('load',[path{gd},'/',name{gd},ext{gd}],'-mat');
        obj(gd,1)	= s.obj;

        obj(gd).LoadFile	= fullfile(path{gd},[name{gd},ext{gd}]);

        printDebugMessage('Info','Loading ''%s'' from disk ... done',[name{gd},ext{gd}])
    end
end