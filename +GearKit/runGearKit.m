clear 

import GearKit.*

pathName        = '/Users/David/Dropbox/David/university/PostDoc/data/cruises/';

%% import BIGO deployments

%%{
dirListCruises 	= dir([pathName,'*_BIGO_data*']);
tmpCruiseIds    = regexp({dirListCruises.name},'([A-Z]+\d+)_BIGO_data','tokens');
tmpCruiseIds    = [tmpCruiseIds{:}]';

pathBigos       = {};
for cr = 1:numel(tmpCruiseIds)
    dirListBIGOs    = dir([pathName,dirListCruises(cr).name,'/BIGO-*']);
    tmpBIGOIds      = regexp({dirListBIGOs.name},'(BIGO\-[I]{1,2}\-\d{2})','tokens');
    tmpBIGOIds      = [tmpBIGOIds{:}]';
    pathBigos       = [pathBigos;strcat(pathName,dirListCruises(cr).name,{'/'},cat(1,tmpBIGOIds{:}))];
end
nBIGOs          = numel(pathBigos);

BIGOs       = bigoDeployment.empty;
for bigo = 1:nBIGOs
    fprintf('\nReading BIGO %d of %d ...\n',bigo,nBIGOs);
    BIGOs	= [BIGOs;bigoDeployment(pathBigos{bigo})];
end

%}

%% import EC deployments

%{
dirListCruises 	= dir([pathName,'*_EC_data*']);
tmpCruiseIds    = regexp({dirListCruises.name},'([A-Z]+\d+)_EC_data','tokens');
tmpCruiseIds    = [tmpCruiseIds{:}]';

pathECs         = {};
for cr = 1:numel(tmpCruiseIds)
    dirListECs    = dir([pathName,dirListCruises(cr).name,'/EC-*']);
    tmpECIds      = regexp({dirListECs.name},'(EC\-\d{2})','tokens');
    tmpECIds      = [tmpECIds{:}]';
    pathECs       = [pathECs;strcat(pathName,dirListCruises(cr).name,{'/'},cat(1,tmpECIds{:}))];
end
nECs     	= numel(pathECs);

ECs         = ecDeployment.empty;
for ec = 1:nECs
    fprintf('\nReading EC %d of %d ...\n',ec,nECs);
    ECs	= [ECs;ecDeployment(pathECs{ec})];
end
%}

%%

ECs = ECs.runAnalysis;

%%
figure(5)
clf
ec  = 1;
ii   = 1:1:size(ECs(ec).analysis.velocityRaw,1);


[time,data,~]     = ECs(ec).getData({'velocityU','velocityV','velocityW','oxygen'},...
                            'SensorId',             'NortekVector',...
                            'DeploymentDataOnly',	true);
XData2  = data{1}(ii);
YData2  = data{2}(ii);
ZData2  = data{3}(ii);
scatter3(XData2,YData2,ZData2,...
    'Marker',               '.',...
    'MarkerEdgeColor',      0.5.*ones(1,3))
hold on

% XData   = ECs(ec).analysis.velocity(ii,1);
% YData   = ECs(ec).analysis.velocity(ii,2);
% ZData   = ECs(ec).analysis.velocity(ii,3);
% scatter3(XData,YData,ZData,...
%     'Marker',               '.',...
%     'MarkerEdgeColor',      'k')

%%{
    s = 0.4;
    i = ECs(ec).analysis.coordinateSystemUnitVectors(1,:).*s;
    j = ECs(ec).analysis.coordinateSystemUnitVectors(2,:).*s;
    k = ECs(ec).analysis.coordinateSystemUnitVectors(3,:).*s;
    plot3([0,1].*s,[0,0].*s,[0,0].*s,'r','LineWidth',2)
    plot3([0,0].*s,[0,1].*s,[0,0].*s,'g','LineWidth',2)
    plot3([0,0].*s,[0,0].*s,[0,1].*s,'b','LineWidth',2)
    plot3([0,i(1)],[0,i(2)],[0,i(3)],'--r','LineWidth',2)
    plot3([0,j(1)],[0,j(2)],[0,j(3)],'--g','LineWidth',2)
    plot3([0,k(1)],[0,k(2)],[0,k(3)],'--b','LineWidth',2)

    hax                 = gca;
    hax.DataAspectRatio = ones(1,3);
%}


axis image
xlabel('u')
ylabel('v')
zlabel('w')

%% plot calibration
%{
figure(2)
clf

gdObj   = BIGOs(2);

views   = [0 0 1; % time-signal
           0,-1,0; % time-value
           1,0,0]; % signal-value
f = 1;
nsp  = 3;
for ii = 1:nsp
    subplot(nsp,1,ii,'NextPlot','add')
    mask    = gdObj.calibration{:,'SignalName'} == 'oxygen';
    XData1  = gdObj.calibration{mask,'CalibrationTime'};
    YData1  = gdObj.calibration{mask,'Signal'};
    ZData1  = gdObj.calibration{mask,'Value'};


%     mask    = gdObj.calibration{:,'SignalName'} == 'analogInput2';
%     XData2  = gdObj.calibration{mask,'CalibrationTime'};
%     YData2  = gdObj.calibration{mask,'Signal'};
%     ZData2  = gdObj.calibration{mask,'Value'};

    scatter3(XData1,YData1,ZData1,...
        'MarkerFaceColor',      'none',...
        'MarkerEdgeColor',      'k')
%     scatter3(XData2,YData2,ZData2,...
%         'MarkerFaceColor',      'none',...
%         'MarkerEdgeColor',      'r')


    [XData3,YData3]	= gdObj.getData('oxygen',...
                        'SensorIndex',          [],...
                        'Raw',                  true,...
                        'DeploymentDataOnly',   true);
    XData3  = cat(1,XData3{:});
    YData3  = cat(1,YData3{:});
    [~,ZData3]    	= gdObj.getData('oxygen',...
                        'SensorIndex',          [],...
                        'Raw',                  false,...
                        'DeploymentDataOnly',   true);
    ZData3  = cat(1,ZData3{:});


    scatter3(XData3(1:f:end),YData3(1:f:end,1),ZData3(1:f:end,1),...
        'Marker',           '.',...
        'MarkerEdgeColor',  'k')
%     scatter3(XData3(1:f:end),YData3(1:f:end,2),ZData3(1:f:end,2),...
%         'Marker',           '.',...
%         'MarkerEdgeColor',  'r')

    view(views(ii,:))
    
    xlabel('Time')
    ylabel('Signal')
    zlabel('Value')
end

%}

%%
%{
BIGOs.plot;
ECs.plot;
%}

%%
%{
    hfig = BIGOs(2).plot('oxygen','salinity','temperature','lightIntensity');
    print(hfig,['/Users/David/Dropbox/David/university/PostDoc/cruise planning/EMB238/short cruise report/ressources/',hfig.Name],'-dpdf')
    print(hfig,'-r150',['/Users/David/Dropbox/David/university/PostDoc/cruise planning/EMB238/short cruise report/ressources/',hfig.Name],'-dpng')
%}