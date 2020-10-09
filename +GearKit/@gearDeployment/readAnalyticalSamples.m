function obj = readAnalyticalSamples(obj)
% READANALYTICALSAMPLES

    import DataKit.importTableFile
    
 	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading %s analytical samples data... \n',obj.gearType);
	end
    
    try
        filename    = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_analyticalSamples.xlsx'];
        tbl         = importTableFile(filename);
        
        mask    = all(tbl{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2);
        obj.analyticalSamples   = tbl(mask,:);
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                if obj.debugger.debugLevel >= 'Verbose'
                    fprintf('VERBOSE: no file with name ''%s'' found.\n',filename);
                end
            otherwise
                rethrow(ME)
        end
    end
    
    
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading %s analytical samples data... done\n',obj.gearType);
	end
end