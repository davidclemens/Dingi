function varargout = exportProtocol(obj,varargin)
% COMPILEPROTOCOL
        
    import UtilityKit.Utilities.table.writeTableFile
    
    if nargin == 1
        filename	= '';
    elseif nargin == 2
        filename	= varargin{1};
        if ~ischar(filename)
            error('Dingi:GearKit:bigoDeployment:exportProtocol:wrongDatatype',...
                'The export filename has to be char.')
        end
    else
        error('Dingi:GearKit:bigoDeployment:exportProtocol:wrongNumberOfArguments',...
            'Wrong number of arguments.')
    end
    
    tbl     = table();
    for oo = 1:numel(obj)
        newTable                = obj(oo).protocol(:,{'Subgear','SampleId','Event','StartTime','EndTime','Time','TimeRelative','Duration'});
        newTable{:,'Cruise'}	= obj(oo).cruise;
        newTable{:,'Gear'}  	= obj(oo).gear;        
        tbl                     = [tbl;newTable];
    end
    
    tbl     = tbl(:,{'Cruise','Gear','Subgear','SampleId','Event','StartTime','EndTime','Time','TimeRelative','Duration'});
    
    if ~isempty(filename)
        [~,~,ext] = fileparts(filename);
        switch ext
            case '.xlsx'
                try
                    writeTableFile(tbl,filename);
                catch ME
                    rethrow(ME);
                end
            otherwise
                error('Dingi:GearKit:bigoDeployment:exportProtocol:unknownExportFileExtension',...
                    'The filextension ''%s'' for the export is not implemented yet.',ext)
        end
        fprintf('Protocol was sucessfully exported to:\n\t%s\n',filename)
    else
        varargout{1} = tbl;
    end
end
