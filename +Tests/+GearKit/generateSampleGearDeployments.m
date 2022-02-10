function [gd,subclassNames,dataSetNames] = generateSampleGearDeployments()
% generateSampleGearDeployments  Generates sample subclass instances
%   GENERATESAMPLEGEARDEPLOYMENTS Generates instances of all 
%   GearKit.gearDeployment subclass filled with sample data
%
%   Syntax
%     gd = generateSampleGearDeployments()
%     [gd,subclassNames] = generateSampleGearDeployments()
%     [gd,subclassNames,dataSetNames] = generateSampleGearDeployments()
%
%   Description
%     gd = generateSampleGearDeployments() generates instances of all 
%   	GearKit.gearDeployment subclass filled with sample data
%     [gd,subclassNames] = generateSampleGearDeployments() additionally
%       returns the list of the subclass names
%     [gd,subclassNames,dataSetNames] = generateSampleGearDeployments()
%       additionally returns the list of data set names
%
%   Example(s)
%     gd = generateSampleGearDeployments() returns a struct with a field
%       name for each subclass of GearKit.gearDeployment of which each
%       contains an array of subclass instance handles.
%
%
%   Input Arguments
%
%
%   Output Arguments
%     gd - sample gearDeployments subclasses
%       struct
%         A struct with a field name for each subclass of
%         GearKit.gearDeployment of which each contains an array of
%         subclass instance handles.
%     subclassNames - list of subclasses
%       cellstr vector
%         A cellstr vector with the subclass names used.
%     dataSetNames - list of dataset names
%       cellstr vector
%         A cellstr vector with the dataset names used.
%
%   Name-Value Pair Arguments
%
%
%   See also
%
%   Copyright (c) 2022 David Clemens (dclemens@geomar.de)
%

    [dataPools,dataSetNames]	= generateDataPools();
    nDataPools                  = numel(dataPools);
    
    infoDingi   = what('Dingi');
   	pathDingi   = infoDingi.path;
    subclasses  = getSubclasses('GearKit.gearDeployment',[pathDingi,'/GearKit']);
    nSubclasses = numel(subclasses);
    
    gd  = struct();
    subclassNames = cell(nSubclasses,1);
    for sub = 1:nSubclasses
        subclassNameFull    = subclasses(sub).Class;
        subclassNames{sub}	= subsref(strsplit(subclassNameFull,'.'),struct('type','{}','subs',{{2}}));
        for dp = 1:nDataPools
            gd.(subclassNames{sub})(dp)  = eval(subclassNameFull);
            
            gd.(subclassNames{sub})(dp).data            	= dataPools(dp);
            gd.(subclassNames{sub})(dp).timeDeployment    	= datetime(2020,10,2,15,42,50);
            gd.(subclassNames{sub})(dp).timeOfInterestStart	= datetime(2020,10,2,15,52,50);
            gd.(subclassNames{sub})(dp).timeOfInterestEnd 	= datetime(2020,10,2,19,32,38);
            gd.(subclassNames{sub})(dp).timeRecovery      	= datetime(2020,10,2,19,42,38);
            gd.(subclassNames{sub})(dp).cruise            	= categorical({'M100'});
            gd.(subclassNames{sub})(dp).gear             	= [char(gd.(subclassNames{sub})(dp).gearType),'-',num2str(dp,'%02u')];
        end
    end    
    
    function [dp,dataSetNames] = generateDataPools()
        % Dummy data    
        % Creates data pools with a single (s) or multiple (m),
        % independent (I) or dependent (D) variables.
        
        setNames    = {...
            'IsDs',...
            'ImDs',...
            'IsDm',...
            'ImDm'
            };
        dData(1)	= struct('IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independent','Dependent'}}),...
                         'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independent','Independent','Dependent'}}),...
                         'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independent','Dependent','Dependent'}}),...
                         'ImDm',            struct('Variable',          {{'Time','Depth','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,16000)',reshape(repmat(0:15,1000,1),[],1),randn(16000,1),randn(16000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independent','Independent','Dependent','Dependent'}})...
                        );
        dData(2)	= struct('IsDs',            struct('Variable',          {{'Time','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0}},...
                                                   'VariableType',      {{'Independent','Dependent'}}),...
                         'ImDs',            struct('Variable',          {{'Time','Depth','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',reshape(repmat(0:30,1000,1),[],1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independent','Independent','Dependent'}}),...
                         'IsDm',            struct('Variable',          {{'Time','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',randn(31000,1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0}},...
                                                   'VariableType',      {{'Independent','Dependent','Dependent'}}),...
                         'ImDm',            struct('Variable',          {{'Time','Z','Nitrate','Oxygen'}},...
                                                   'Data',              cat(2,linspace(0,3600,31000)',reshape(repmat(0:30,1000,1),[],1),randn(31000,1),randn(31000,1)),...
                                                   'VariableOrigin',    {{datetime(2020,10,2,15,32,50),0,0,0}},...
                                                   'VariableType',      {{'Independent','Independent','Dependent','Dependent'}})...
                        );

        uniqueCombinations  = nchoosek(1:numel(setNames),2);
        nUniqueCombinations = size(uniqueCombinations,1);
        dataSetNames        = cell(nUniqueCombinations,1);
        for ii = 1:nUniqueCombinations
            
            dp(ii)	= DataKit.dataPool();
            for jj = 1:numel(dData)
                nameOfSet	= setNames{uniqueCombinations(ii,jj)};

                dp(ii) 	= dp(ii).addVariable(dData(jj).(nameOfSet).Variable,dData(jj).(nameOfSet).Data,...
                            'VariableType',     dData(jj).(nameOfSet).VariableType,...
                            'VariableOrigin',   dData(jj).(nameOfSet).VariableOrigin);
            end
            
            dataSetNames{ii} = strjoin(setNames(uniqueCombinations(ii,:)),'_');
        end
    end    
end