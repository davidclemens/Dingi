function [time,varargout] = getAnalyticalData(obj,parameter,varargin)
% GETANALYTICALDATA
        
    import DataKit.importTableFile
 
    if numel(obj) > 1
        error('GearKit:gearDeployment:getAnalyticalData:objSize',...
              'getData only works in a scalar context. To get data from multiple instances, loop over all.')
    end
   
    if ~isa(parameter,'uint16')
        error('GearKit:gearDeployment:getAnalyticalData:invalidParameterType',...
              'The requested parameter has to be specified as a uint16.')
    end
   	parameter	= parameter(:);
    nParameter 	= numel(parameter);
    
    analyticalSamples	= outerjoin(obj.analyticalSamples,obj.protocol,...
                            'Keys',             {'Subgear','SampleId'},...
                            'MergeKeys',        true,...
                            'RightVariables',   {'Time','TimeRelative'},...
                            'Type',             'left');

    % only keep table entries with requested parameter
    [maskAnalyticalSamples,indAnalyticalParameterIds] = ismember(analyticalSamples{:,'ParameterId'},parameter);
    analyticalSamples               = analyticalSamples(maskAnalyticalSamples,:);
    indAnalyticalParameterIds       = indAnalyticalParameterIds(maskAnalyticalSamples);

    [uSampleIds,~,indSampleIds]     = unique(analyticalSamples(:,{'Subgear','SampleId'}),'rows');
    nSampleIds                      = size(uSampleIds,1);

    % average replicates
    time = accumarray([indSampleIds,indAnalyticalParameterIds],datenum(analyticalSamples{:,'Time'}),[],@nanmean);
    data = accumarray([indSampleIds,indAnalyticalParameterIds],analyticalSamples{:,'Value'},[],@nanmean);
    
    % accumulate according to Subgear and SourceId
 	dataSourceId                        = regexprep(cellstr(uSampleIds{:,'SampleId'}),'\d+$','');
    [uDataSourceId,~,indDataSourceId] 	= unique(cat(2,uSampleIds(:,'Subgear'),cell2table(dataSourceId,'VariableNames',{'DataSourceId'})),'rows');


	time    = accumarray([repmat(indDataSourceId,nParameter,1),reshape(repmat(1:nParameter,nSampleIds,1),[],1)],time(:),[],@(x) {x});
    data    = accumarray([repmat(indDataSourceId,nParameter,1),reshape(repmat(1:nParameter,nSampleIds,1),[],1)],data(:),[],@(x) {x});
    
    % compile metadata
    meta	= struct('dataSourceType',      categorical({'analyticalSample'}),...
                     'dataSourceId',        num2cell(categorical(uDataSourceId{:,'DataSourceId'})),...
                     'dataSourceDomain',    num2cell(categorical(uDataSourceId{:,'Subgear'})),...
                     'mountingLocation',    [],...
                     'dependantVariables',  {'time'});
    
    dataNotEmpty        = ~cellfun(@isempty,data) | ~cellfun(@isempty,time);
    maskEmtpyDataSource = ~all(~dataNotEmpty,2);

    
    data            = data(maskEmtpyDataSource,:);
    time            = time(maskEmtpyDataSource,:);
    meta            = meta(maskEmtpyDataSource);
    
	% only keep one replicate of the time
 	time    = time(:,1);
                 
    % TODO
    if nargout >= 2
        varargout{1}	= data;
    end
    if nargout >= 3
        varargout{2}    = meta;
    end
end