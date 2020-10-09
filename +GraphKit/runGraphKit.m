clear

import GraphKit.*

load('/Users/David/Documents/Education/University/Christian-Albrechts-Universität zu Kiel/M.Sc. Marine Geosciences/3. Semester (WS 15:16)/The Oceans Role in Climate:Quantitative Proxies/pCO2 reconstruction/Barnola1987.mat');
load('/Users/David/Documents/Education/University/Christian-Albrechts-Universität zu Kiel/M.Sc. Marine Geosciences/3. Semester (WS 15:16)/The Oceans Role in Climate:Quantitative Proxies/pCO2 reconstruction/Mueller1994.mat')
load('/Users/David/Documents/Education/University/Christian-Albrechts-Universität zu Kiel/M.Sc. Marine Geosciences/3. Semester (WS 15:16)/The Oceans Role in Climate:Quantitative Proxies/pCO2 reconstruction/Petit1999.mat')

Barnola1987.AgeGas 	= 1e-3.*Barnola1987.AgeGas;
Mueller1994.Age     = Mueller1994.Age;
Petit1999.Age       = Petit1999.Age;

XData1  = (1:999)';
XData2  = (1:10:900)';
XData3  = (-210:20:400)';

YData1  = 1.01.*sind(XData1);
YData21  = -1.5.*XData2 + 300 + 500.*sind(XData2.*500) + (rand(size(XData2)) - 0.5).*50;
YData22  = -1.8.*XData2 - 120 + (rand(size(XData2)) - 0.5).*5;
YData3  = -3.*XData3 - 200 + 500.*sind(XData3.*100);




ny      = 4;
nx      = 1;

%%
figure(5)
clf

hax1    = subplot(ny,nx,1,'NextPlot','add');
    plot(Barnola1987.AgeGas,Barnola1987.CO2mean,...
        'Marker',       '.');
    plot(Petit1999.Age,Petit1999.CO2,...
        'Marker',       '.');
    
hax2    = subplot(ny,nx,2,'NextPlot','add');
    plot(Mueller1994.Age,Mueller1994.d13Corg,...
        'Marker',       '.');
    
hax3    = subplot(ny,nx,3,'NextPlot','add');
    plot(Mueller1994.Age,Mueller1994.TOC,...
        'Marker',       '.');
    
hax4    = subplot(ny,nx,4,'NextPlot','add');
    plot(Mueller1994.Age,Mueller1994.CaCO3,...
        'Marker',       '.');
    
hag1 = axesGroup([hax1,hax2,hax3,hax4],...
        'CommonAxis',       'XAxis');
    
%%
figure(6)
clf

hax1    = subplot(ny,nx,1,'NextPlot','add');
    plot(Barnola1987.CO2mean,Barnola1987.AgeGas,...
        'Marker',       '.');
    plot(Petit1999.CO2,Petit1999.Age,...
        'Marker',       '.');
    
hax2    = subplot(ny,nx,2,'NextPlot','add');
    plot(Mueller1994.d13Corg,Mueller1994.Age,...
        'Marker',       '.');
    
hax3    = subplot(ny,nx,3,'NextPlot','add');
    plot(Mueller1994.TOC,Mueller1994.Age,...
        'Marker',       '.');
    
hax4    = subplot(ny,nx,4,'NextPlot','add');
    plot(Mueller1994.CaCO3,Mueller1994.Age,...
        'Marker',       '.');


hag2 = axesGroup([hax1,hax2,hax3,hax4],...
        'CommonAxis',       'YAxis');
