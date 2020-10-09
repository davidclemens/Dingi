function varargout = exportData(obj,parameter,filename,varargin)
% EXPORTDATA
	
    
    error('TODO: not fully written yet.')

    % parse Name-Value pairs
    optionName          = {'SensorIndex','SensorId','Raw','DeploymentDataOnly','RelativeTime'}; % valid options (Name)
    optionDefaultValue  = {[],'',false,false,''}; % default value (Value)
    [sensorIndex,... % only return sensor data from sensors at index within the sensor array
     sensorId,... % only return sensor data from sensors with sensorId
     raw,... % return uncalibrated data
     deploymentDataOnly,... % only keep time series data that's within the deployment & recovery times
     relativeTime,... % return time as relative time (y, d, h, m, s, ms)
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
 
 
    if ~ischar(filename)
        error('GearKit:gearDeployment:exportData:wrongDatatype',...
            'The export filename has to be char.')
    end
    
    obj.getData
    
    if ~isempty(filename)
        [~,~,ext] = fileparts(filename);
        switch ext
            case '.xlsx'
                try
                    writeTableAndHeader(tbl,filename);
                catch ME
                    rethrow(ME);
                end
            otherwise
                error('GearKit:gearDeployment:exportData:unknownExportFileExtension',...
                    'The filextension ''%s'' for the export is not implemented yet.',ext)
        end
        fprintf('Data was sucessfully exported to:\n\t%s\n',filename)
    else
        varargout{1} = tbl;
    end
end