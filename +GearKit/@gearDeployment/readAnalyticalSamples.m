function obj = readAnalyticalSamples(obj)
% READANALYTICALSAMPLES

    import DataKit.importTableFile
    
 	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading %s analytical samples data... \n',obj.gearType);
	end
    
    try
        filename    = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_analyticalSamples.xlsx'];
        tbl         = importTableFile(filename);
        
        mask        = all(tbl{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2);

        % append time data
        obj.analyticalSamples   = tbl(mask,:);
        obj.analyticalSamples	= outerjoin(obj.analyticalSamples,obj.protocol,...
                                    'Keys',             {'Subgear','SampleId'},...
                                    'MergeKeys',        true,...
                                    'RightVariables',   {'Time','TimeRelative'},...
                                    'Type',             'left');
        
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                if obj.debugger.debugLevel >= 'Verbose'
                    fprintf('VERBOSE: no file with name ''%s'' found.\n',filename);
                end
            case 'MATLAB:noSuchMethodOrField'
                if logical(regexp(ME.message,'No appropriate method, property, or field ''protocol'' for class ''.+''\.'))
                    if obj.debugger.debugLevel >= 'Verbose'
                        fprintf('VERBOSE: no protocol data found. Appending empty table\n');
                    end
                    obj.analyticalSamples{:,{'Time','TimeRelative'}} = repmat({NaT,NaN},size(obj.analyticalSamples,1),1);
                else
                    rethrow(ME)
                end
            otherwise
                rethrow(ME)
        end
    end
    obj.analyticalSamples{:,'isOutlier'} = false;
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading %s analytical samples data... done\n',obj.gearType);
	end
end