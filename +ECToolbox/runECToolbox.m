%% SETUP ENVIRONMENT
clear

import ECToolbox.*

%% DEFINITIONS
% define base directory
baseDir         = '/Users/David/Dropbox/David/university/PostDoc/data/analysis/';

% define project directory
projDir         = [baseDir,'BalticSea/'];

% vecFileName     = [projDir,'ressources/Test/EC2T03_03_3.VEC'];
% vecFileName     = [projDir,'ressources/EC Hz-Test Raw/Hz test.vec'];
% vecFileName     = [projDir,'ressources/EC Hz-Test PT100 Raw/Hztest_pt100.vec'];
% vecFileName     = [projDir,'ressources/32hz Test/32hz 30min, temp 15min/32Hz test pt100 30min.vec'];
% vecFileName     = '/Users/David/Dropbox/David/university/PostDoc/data/cruises/EMB238_EC_data/EC-01/EC-01_Vector_CalibrationBefore.vec';
vecFileNames    = {'/Users/David/Dropbox/David/university/PostDoc/data/cruises/EMB238_EC_data/EC-01/EC-01_Vector.vec';...
                   '/Users/David/Dropbox/David/university/PostDoc/data/cruises/EMB238_EC_data/EC-02/EC-02_Vector.vec'};

for ff = 1:numel(vecFileNames)
    EC(ff,1)   = NortekVecFile(vecFileNames{ff},...
                'DebugLevel',       'Verbose',...
                'Reindex',          false);
end
     
%% Rotate after Lee et al. (2005)

% [k,b0] = ECToolbox.unit_vector_k(EC(1).velocity);
% [i,j] = ECToolbox.unit_vector_ij(EC(1).velocity(1,:),k);

%%
% [~,hlnk1] = vec.plot(...
%     'Parameters',   {'temperature','velocityU','analogInput1','analogInput2'},...
%     'Smooth',       [false,true,true,true]);
[~,hlnk1] = EC(2).plot(...
    'Parameters',   {'velocityU','velocityV','analogInput2'},...
    'Smooth',       [true,true,true]);
        
%%
% ef      = EddyFlux(vec.timeseriesVelocity,vec.timeseriesAnalogInput1);

ind = 1;
%%
%{
figure(1)
clf

ts          = resample(ef.velocityTimeseries,ef.velocityTimeseries.Time);
tsDespiked	= resample(ef.velocityTimeseriesDespiked,ef.velocityTimeseriesDespiked.Time);

plot(ts.Data(:,ind),'b')
hold on
plot(tsDespiked.Data(:,ind),'r')
%}
%% PROCESSING
%{
figure(2)
clf

S       = ts.Data(:,ind);
Sds     = tsDespiked.Data(:,ind);
%S   = vecnorm(ts.Data,2,2); % magnitude of vector = vectnorm(V,2,2)

fs      = vec.sampleRateRapid;
fN      = 0.5*fs;
N       = numel(S);
fR      = (1/N)*fs;

X       = fftshift(fft(S));
Xds     = fftshift(fft(Sds));
f       = (-N/2:N/2 - 1)*(fs/N);
PSD     = abs(X).^2/(N*fs);
PSDds   = abs(Xds).^2/(N*fs);

%plot(period,power)

plot(f,movmean(PSD,fs*5),'b')
hold on
plot(f,movmean(PSDds,fs*5),'r')
hsp     = gca;
set(hsp,...
    'YScale',   'log',...
    'XScale',   'log',...
    'NextPlot', 'add')
line(fs.*[1,1],hsp.YLim,'Color','k')
line(fR.*[1,1],hsp.YLim,'Color','k')

xlabel('period (s)')
ylabel('Power Spectrum Density (m^2s^{-2} cps^{-1})')

%}
%% 

mmWinRapid  = EC.sampleRateRapid*60;
mmWinSlow   = EC.sampleRateSlow*60;


%% Calibration


CalT1   = 20.55;
CalT2   = 20.72;
CalS  	= 0;
Cal1O2  = [0,csatO2(CalS,CalT1)]; % µM
Cal2O2  = [0,csatO2(CalS,CalT2)]; % µM
CalTime = [-4,2.2].*60^2; % h


PICO1           = struct();
PICO2           = struct();
Ref             = struct();
PICO1.CalData   = [0.038, 284;
                   1.95,  288.06]; % µM
PICO2.CalData  	= [0.009, 284;
                   2.21   302.86]; % µM
Ref.CalData  	= [0.01,  284;
                  -0.207  282.4]; % µM


PICO1.Cal1      = fitlm(PICO1.CalData(1,:),Cal1O2,'linear');
PICO1.Cal2      = fitlm(PICO1.CalData(2,:),Cal2O2,'linear');
PICO1.CalTimeIntercept	= fitlm(CalTime,[PICO1.Cal1.Coefficients.Estimate('(Intercept)'),PICO1.Cal2.Coefficients.Estimate('(Intercept)')],'linear');
PICO1.CalTimeSlope      = fitlm(CalTime,[PICO1.Cal1.Coefficients.Estimate('x1'),PICO1.Cal2.Coefficients.Estimate('x1')],'linear');
PICO1.cO2               = @(t,v) feval(PICO1.CalTimeSlope,t).*v + feval(PICO1.CalTimeIntercept,t);


PICO2.Cal1      = fitlm(PICO2.CalData(1,:),Cal1O2,'linear');
PICO2.Cal2      = fitlm(PICO2.CalData(2,:),Cal2O2,'linear');
PICO2.CalTimeIntercept	= fitlm(CalTime,[PICO2.Cal1.Coefficients.Estimate('(Intercept)'),PICO2.Cal2.Coefficients.Estimate('(Intercept)')],'linear');
PICO2.CalTimeSlope      = fitlm(CalTime,[PICO2.Cal1.Coefficients.Estimate('x1'),PICO2.Cal2.Coefficients.Estimate('x1')],'linear');
PICO2.cO2 = @(t,v) feval(PICO2.CalTimeSlope,t).*v + feval(PICO2.CalTimeIntercept,t);

analogInput1      = PICO1.cO2(EC.timeRapidRelative,EC.analogInput1./5.*350);
analogInput2      = PICO2.cO2(EC.timeRapidRelative,EC.analogInput2./5.*350);

 
           


%% VISUALIZATION

hfig            = gobjects();
hsp             = gobjects();

%% FIGURE 01 - 
fig             = 1;
hfig(fig)       = figure(fig);
clf

spnx        = 1;
spny        = 7;
spi         = reshape(1:spnx*spny,spnx,spny)';
    
col     = 1;
row     = 1;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeRapidRelative;
    YData   = movmean(EC.velocity,mmWinRapid,1);
    plot(XData,YData)
    %plot(timeFast,movmean(velDespiked(:,1),mmWinFast,1))
    xlabel('time (h)')
    ylabel('velocity (ms^{-1})')

col     = 1;
row     = 2;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeRapidRelative;
	YData   = movmean(EC.amplitude,mmWinRapid,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('amplitude (counts)')
    
col     = 1;
row     = 3;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeRapidRelative;
	YData   = movmean(EC.correlation,mmWinRapid,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('correlation (%)')
    
col     = 1;
row     = 4;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add',...
                                    'YDir',     	'reverse');
	XData   = EC.timeRapidRelative;
	YData   = movmean(EC.pressure,mmWinRapid,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('pressure (dbar)')
    
col     = 1;
row     = 5;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeSlowRelative;
	YData   = movmean(EC.compass,mmWinSlow,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('head, pitch & roll (°)')
    
col     = 1;
row     = 6;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeSlowRelative;
	YData   = movmean(EC.temperature,mmWinSlow,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('temp (°C)')
    
    
col     = 1;
row     = 7;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',     'add');
	XData   = EC.timeRapidRelative;
	YData   = movmean([EC.analogInput1,EC.analogInput2],mmWinRapid,1);
    plot(XData,YData)
    xlabel('time (h)')
    ylabel('analog in (V)')

hlnk{fig} = linkprop(hsp(spi(1:spnx*spny),fig),{'xlim'});

%% FIGURE 02 - Calibration Test 01
fig             = 2;
hfig(fig)       = figure(fig);
set(hfig(fig),...
    'Name',     'EC lab test ADV analog in')
clf

spnx        = 5;
spny        = 1;
spi         = reshape(1:spnx*spny,spnx,spny)';
    
timeKeep    = [4.113e4:4.536e4,1.077e5:1.272e5,1.907e5:2.028e5,2.604e5:2.743e5,3.295e5:3.432e5,4e5:5.15e5,5.261e5:numel(EC.analogInput1)];

clrmap      = cbrewer('qual','Paired',12);

col     = 1:4;
row     = 1;
hsp(spi(row,col(1)),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	title(['Oxygen timeline of',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),' PICO1\color{black} and ',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'PICO2'])
        
    XData               = EC.timeRapidRelative;
	YData0              = [EC.analogInput1,EC.analogInput2]; % uncalibrated
	%YData0              = [analogInput1,analogInput2]; % calibrated
    YData1              = YData0;
    %YData1(timeKeep,:)  = NaN;
	YData               = movmean(YData1,mmWinRapid,1);
    
    text(6300,Cal1O2(2),['start O_{2 sat.} @ ',num2str(CalT1,'%5.2f'),' °C'],'VerticalAlignment','bottom')
    text(6300,Cal2O2(2),['end O_{2 sat.} @ ',num2str(CalT2,'%5.2f'),' °C'],'VerticalAlignment','top')
    
%     hp0     = plot(XData,YData0,'Color',.9.*ones(1,3));
    
    
    plot(XData([1,end]),Cal1O2([2 2]),'k--')
    plot(XData([1,end]),Cal2O2([2 2]),'k--')
    
    hp1     = plot(XData,YData1);
    hp2     = plot(XData,YData,...
                'LineWidth',    2);
    set(hp1,...
        {'Color'},  num2cell(clrmap([1,3],:),2));
    set(hp2,...
        {'Color'},  num2cell(clrmap([2,4],:),2));
    ylim([min(YData1(:)),max(YData1(:))])
    xlabel('time (min)')
    ylabel('O_2 (µM)')
    
col     = 5;
row     = 1;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	title(['Oxygen correlation of',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),' PICO1\color{black} and ',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'PICO2'])
                                

    plot([min(YData(:)),max(YData(:))],[min(YData(:)),max(YData(:))],'k')
    s1     = scatter(YData1(:,1),YData1(:,2),'.','MarkerEdgeColor',0.75.*ones(1,3));
    s2     = scatter(YData(:,1),YData(:,2),'k.');
%     hp2     = plot(timeFast,YData,...
%                 'LineWidth',    2);
%     set(hp1,...
%         {'Color'},  num2cell(clrmap([1,3],:),2));
%     set(hp2,...
%         {'Color'},  num2cell(clrmap([2,4],:),2));
%     ylim([min(YData1(:)),max(YData1(:))])
    xlabel(['O_2 PICO1',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),'\color{black} (µM)'])
    ylabel(['O_2 PICO2',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'\color{black} (µM)'])
    axis image
    
%% FIGURE 03 - Calibration Test 02
fig             = 3;
hfig(fig)       = figure(fig);
set(hfig(fig),...
    'Name',     'EC lab test ADV analog in')
clf

spnx        = 5;
spny        = 1;
spi         = reshape(1:spnx*spny,spnx,spny)';
    
timeKeep    = [1.001,1.231;...
               1.366,1.414;...
               1.705,2.037;...
               2.122,2.386;...
               2.493,2.759;...
               2.853,3.118;...
               3.211,3.482;...
               3.572,3.832;...
               3.920,3.948;...
               4.074,4.161;...
               4.243,4.434;...
               4.503,4.560;...
               4.829,4.850;...
               5.166,5.249].*3600.*64;
timeKeep    = round(timeKeep);
timeDismiss = [[1;timeKeep(1:end,2)],[timeKeep(1:end,1);numel(EC.timeRapidRelative)]];
timeDismiss = arrayfun(@(s,e) s:e,timeDismiss(:,1),timeDismiss(:,2),'un',0);
timeDismiss = cat(2,timeDismiss{:})';
clrmap      = cbrewer('qual','Paired',12);

col     = 1:4;
row     = 1;
hsp(spi(row,col(1)),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	title(['Oxygen timeline of',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),' PICO1\color{black} and ',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'PICO2'])
        
    XData               = EC.timeRapid;
	YData0              = [EC.analogInput1,EC.analogInput2]; % uncalibrated
    YData1              = YData0;
%     YData1(timeDismiss,:)  = NaN;
	YDataSmooth       	= movmean(YData1,mmWinRapid,1);
        
    hp1     = plot(XData,YData1);
    hp2     = plot(XData,YDataSmooth,...
                'LineWidth',    2);
    set(hp1,...
        {'Color'},  num2cell(clrmap([1,3],:),2));
    set(hp2,...
        {'Color'},  num2cell(clrmap([2,4],:),2));
    ylim([min(YData1(:)),max(YData1(:))])
    xlabel('time (min)')
    ylabel('O_2 (µM)')
    
col     = 5;
row     = 1;
hsp(spi(row,col),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	title(['Oxygen correlation of',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),' PICO1\color{black} and ',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'PICO2'])
                                

    plot([min(YData1(:)),max(YData1(:))],[min(YData1(:)),max(YData1(:))],'k')
    s1     = scatter(YData1(:,1),YData1(:,2),'.','MarkerEdgeColor',0.75.*ones(1,3));
    s2     = scatter(YDataSmooth(:,1),YDataSmooth(:,2),'k.');
    
    xlabel(['O_2 PICO1',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(2,:),'%6.3f')),' ',','),'}')),'\color{black} (µM)'])
    ylabel(['O_2 PICO2',strjoin(strcat('\color[rgb]{',strrep(cellstr(num2str(clrmap(4,:),'%6.3f')),' ',','),'}')),'\color{black} (µM)'])
    axis image
    
%% FIGURE 04 - Probe Check
fig             = 4;
hfig(fig)       = figure(fig);
set(hfig(fig),...
    'Name',     'Probe Check')
clf

spnx        = 1;
spny        = 2;
spi         = reshape(1:spnx*spny,spnx,spny)';
   
col     = 1;
row     = 1;
hsp(spi(row,col(1)),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	XData   = 1:size(EC.vectorProbeCheckData.amplitude,1);
    YData   = EC.vectorProbeCheckData.amplitude;
    plot(XData,YData)
    xlabel('cell')
    ylabel('amplitude')
   
col     = 1;
row     = 2;
hsp(spi(row,col(1)),fig) = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add',...
                                    'FontSize',         16,...
                                    'TitleFontWeight',	'normal');
	XData   = 0.5:size(EC.vectorProbeCheckData.amplitude,1);
    YData   = [NaN(double(size(EC.vectorProbeCheckData.amplitude,1) > 0),3);diff(EC.vectorProbeCheckData.amplitude,1,1)];
    plot(XData,YData)
    xlabel('cell')
    ylabel('d(amplitude)/d(cell)')
    
hlnk{fig} = linkprop(hsp(spi(1:spnx*spny),fig),{'xlim'});