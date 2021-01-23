function [time,varargout] = getAnalyticalData(obj,parameter,varargin)
% GETANALYTICALDATA
        
    import DataKit.importTableFile
 
    if numel(obj) > 1
        error('Dingi:GearKit:gearDeployment:getAnalyticalData:objSize',...
              'getData only works in a scalar context. To get data from multiple instances, loop over all.')
    end
   
    if ~isa(parameter,'uint16')
        error('Dingi:GearKit:gearDeployment:getAnalyticalData:invalidParameterType',...
              'The requested parameter has to be specified as a uint16.')
    end
   	parameter	= parameter(:);
    nParameter 	= numel(parameter);
    
    analyticalSamples	= obj.analyticalSamples;
    
    % only keep table entries with requested parameter
    [maskAnalyticalSamples,indAnalyticalParameterIds] = ismember(analyticalSamples{:,'ParameterId'},parameter);
    analyticalSamples               = analyticalSamples(maskAnalyticalSamples,:);
    indAnalyticalParameterIds       = indAnalyticalParameterIds(maskAnalyticalSamples);
    nAnalyticalSamples              = size(analyticalSamples,1);
    
    if nAnalyticalSamples == 0
        [time,data,meta,outlier] = GearKit.gearDeployment.initializeGetDataOutputs();
        if nargout >= 2
            varargout{1}	= data;
        end
        if nargout >= 3
            varargout{2}    = meta;
        end
        if nargout >= 4
            varargout{3}    = outlier;
        end
        return
    end
    
    [uSampleIds,~,indSampleIds]     = unique(analyticalSamples(:,{'Subgear','SampleId'}),'rows');
    nSampleIds                      = size(uSampleIds,1);
    
    % find parameter that is missing
    maskParameterExists = ismember(parameter,analyticalSamples{:,'ParameterId'});

    % average replicates
    dataValues  = analyticalSamples{:,'Value'};
    dataValues(analyticalSamples{:,'isOutlier'}) = NaN;
    time    = accumarray([indSampleIds,indAnalyticalParameterIds],datenum(analyticalSamples{:,'Time'}),[nSampleIds,nParameter],@nanmean,NaN);
    data    = accumarray([indSampleIds,indAnalyticalParameterIds],dataValues,[nSampleIds,nParameter],@nanmean,NaN);
 	outlier = accumarray([indSampleIds,indAnalyticalParameterIds],analyticalSamples{:,'isOutlier'},[nSampleIds,nParameter],@any,false);

    % accumulate according to Subgear and SourceId
 	dataSourceId                        = regexprep(cellstr(uSampleIds{:,'SampleId'}),'\d+$','');
    [uDataSourceId,~,indDataSourceId] 	= unique(cat(2,uSampleIds(:,'Subgear'),cell2table(dataSourceId,'VariableNames',{'DataSourceId'})),'rows');

	time    = accumarray([repmat(indDataSourceId,nParameter,1),reshape(repmat(1:nParameter,nSampleIds,1),[],1)],time(:),[],@(x) {x});
    data    = accumarray([repmat(indDataSourceId,nParameter,1),reshape(repmat(1:nParameter,nSampleIds,1),[],1)],data(:),[],@(x) {x});
	outlier	= accumarray([repmat(indDataSourceId,nParameter,1),reshape(repmat(1:nParameter,nSampleIds,1),[],1)],outlier(:),[],@(x) {x});

    if ~iscell(time) || isempty(time)
        [time,data,meta,outlier] = GearKit.gearDeployment.initializeGetDataOutputs();
    else
        % compile metadata
        meta	= struct('dataSourceType',      categorical({'analyticalSample'}),...
                         'dataSourceId',        num2cell(categorical(uDataSourceId{:,'DataSourceId'})),...
                         'dataSourceDomain',    num2cell(categorical(uDataSourceId{:,'Subgear'})),...
                         'mountingLocation',    [],...
                         'dependantVariables',  {'time'},...
                         'name',                {''},...
                         'unit',                {''},...
                         'parameterId',         uint16.empty);

        % replace all NaNs with empty arrays
        dataIsNaN           = cellfun(@(d) all(isnan(d)),data) | cellfun(@(d) all(isnan(d)),time);
        data(dataIsNaN)     = {[]};
        time(dataIsNaN)     = {[]};
        outlier(dataIsNaN)  = {logical.empty};

        % remove empty data sources (rows)
        dataIsEmpty         = ~(~cellfun(@isempty,data) | ~cellfun(@isempty,time));
        maskEmtpyDataSource = ~all(dataIsEmpty,2);
        data                = data(maskEmtpyDataSource,:);
        time                = time(maskEmtpyDataSource,:);
        meta                = meta(maskEmtpyDataSource);
        outlier             = outlier(maskEmtpyDataSource,:);
    end
    
    if nargout >= 2
        varargout{1}	= data;
    end
    if nargout >= 3
        varargout{2}    = meta;
    end
    if nargout >= 4
        varargout{3}    = outlier;
    end
end