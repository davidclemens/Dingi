function [time,varargout] = getSensorData(obj,parameter,varargin)
% GETSENSORDATA returns sensor data from a gearDeployment
% Return sensor data from a parameter from all sensors that hold that
% parameter.
%
% Syntax
%   [time,data] = GETSENSORDATA(obj,parameter)
%
%   [time,data] = GETSENSORDATA(__,Name,Value)
%
%   [time,data,info] = GETSENSORDATA(__)
%
% Description
%   [time,data] = GETSENSORDATA(obj,parameter) returns the time and data of all
%       sensors in a gearDeployment obj that hold the requested parameter.
%
%   [time,data] = GETSENSORDATA(__,Name,Value) specifies additional properties
%       using one or more Name,Value pair arguments.
%
%   [time,data,info] = GETSENSORDATA(__) additionally returns metadata structures
%       with sensor names and parameter units.
%
% Example(s) 
%
%
% Input Arguments
%   obj - gearDeployment instance
%       An instance of the gearDeployment (super)class
%
%
% Output Arguments
%   time - sensor time
%       cell array of datetime vectors
%           Sensor times as cell array of datetimes. The shape is
%           nSensor x 1.
%   data - sensor data
%       cell array of double matrices
%           Sensor data as cell array of double matrices. The shape is
%           nSensor x nParameter.
%   info - sensor info
%       struct
%           Sensor data information as struct with fields id, serialNumber,
%           name & unit.
%
%
% Name-Value Pair Arguments
%   SensorIndex - Indices of sensors to use
%       [] (default) | numeric
%           Only return data from the sensors at SensorIndex in the sensor
%           array. Returns from all sensors by default.
%
%   Raw - Return uncalibrated data
%       false (default) | true
%           Set to true if uncalibrated data should be returned.
%
%   DeploymentDataOnly - Clip data to the deployment interval
%       false (default) | true
%           Set to true if only data during the deployment should be
%           returned.
%
%   RelativeTime - Return time as relative time
%       '' (default) | ms | s | m | h | d | y
%           Returns the time in relative units to the
%           sensor.timeInfo.relativeTimeStart.
%
% 
% See also
%
% Copyright 2020 David Clemens (dclemens@geomar.de)
        
    import DataKit.importTableFile

    % parse Name-Value pairs
    optionName          = {'SensorIndex','SensorId','Raw'}; % valid options (Name)
    optionDefaultValue  = {[],'',false}; % default value (Value)
    [sensorIndex,... % only return sensor data from sensors at index within the sensor array
     sensorId,... % only return sensor data from sensors with sensorId
     raw,... % return uncalibrated data
        ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

 
    if numel(obj) > 1
        error('GearKit:gearDeployment:getSensorData:objSize',...
              'getData only works in a scalar context. To get data from multiple instances, loop over all.')
    end
   
    if ~isa(parameter,'uint16')
        error('GearKit:gearDeployment:getSensorData:invalidParameterType',...
              'The requested parameter has to be specified as a uint16.')
    end
   	parameter	= parameter(:);
               
    nSensor = numel(obj.sensors);
    
    meta	= struct('dataSourceType',      categorical({'sensor'}),...
                     'dataSourceId',        num2cell(categorical({obj.sensors.id}')),...
                     'dataSourceDomain',    num2cell(categorical({obj.sensors.mountingDomain}')),...
                     'mountingLocation',    num2cell(categorical({obj.sensors.mountingLocation}')),...
                     'dependantVariables',  {'time'},...
                     'name',                {''},...
                     'unit',                {''});

    % only keep sensors with requested sensorId
    maskSensor  = true(nSensor,1);
    if ~isempty(sensorId)
        maskSensor  = maskSensor & [meta.dataSourceId]' == sensorId;
    end

    % only keep sensors with requested sensorIndex
    if ~isempty(sensorIndex)
        maskSensor  = maskSensor & (1:nSensor)' == sensorIndex;
    end

    % only keep sensors with requested parameter
    tmpSensorIndex  = obj.parameters{ismember(obj.parameters{:,'ParameterId'},parameter),'SensorIndex'};
    maskSensor     	= maskSensor & ismember((1:numel(obj.sensors))',unique(cat(1,tmpSensorIndex{:})));

    if sum(maskSensor) == 0
        time = cell.empty;
        data = cell.empty;
        meta = meta(false(size(meta)));
    else
        % filter by maskSensor
        [time,data]	= obj.sensors(maskSensor).gd(parameter,...
                                    'Raw',                  raw);
                                
        meta                = meta(maskSensor);
    
        % replace all NaNs with empty arrays
        dataIsNaN           = cellfun(@(d) all(isnan(d)),data) | cellfun(@(d) all(isnan(d)),time);
        data(dataIsNaN)     = {[]};
        time(dataIsNaN)     = {[]};
        
        % remove empty data sources (rows)
        dataIsEmpty         = ~(~cellfun(@isempty,data) | ~cellfun(@isempty,time));
        maskEmtpyDataSource = ~all(dataIsEmpty,2);
        data                = data(maskEmtpyDataSource,:);
        time                = time(maskEmtpyDataSource,:);
        meta                = meta(maskEmtpyDataSource);
    end
    
    if nargout >= 2
        varargout{1}	= data;
    end
    if nargout >= 3
        varargout{2}    = meta;
    end
end