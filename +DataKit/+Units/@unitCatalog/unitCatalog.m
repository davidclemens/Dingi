classdef unitCatalog < handle

    properties (SetAccess = 'private')
        Catalog containers.Map = containers.Map(...
                                    'KeyType', 	'char',...
                                    'ValueType','any')
    end
    properties (Dependent)
        Count
        Names
    end
    properties (Dependent, Access = 'private')
        Keys
    end

    % Constructor
    methods
        function obj = unitCatalog(varargin)
            
            if nargin == 0
                fileParts       = split(mfilename('fullpath'),filesep);
                fileParts{end}  = 'default_en.txt';
                fileName        = fullfile(fileParts{:});
                obj = DataKit.Units.unitCatalog.fromPint(fileName);
                return
            end
        end
    end

    methods
        addUnit(name,links,symbol,alias)
        addDimension(name,links)
        addPrefix(name,value,symbol,alias)
        addAlias(name,alias)
    end
    
    methods %(Access = protected)
        addEntries(obj,name,object)
    end

    % Overloaded
    methods
        varargout = subsref(obj,S)
    end
    
    methods (Static)
        obj = fromXML(file)
        obj = fromPint(file)
        obj = fromCache(file)
    end
    
    % GET
    methods
        function count = get.Count(obj)
            count = obj.Catalog.Count;
        end
        function names = get.Names(obj)
            names = reshape(obj.Catalog.keys,[],1);
        end
        function keys = get.Keys(obj)
            keys = reshape(obj.Catalog.keys,[],1);
        end
    end
end
