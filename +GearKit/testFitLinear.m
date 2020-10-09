clear

import GearKit.*

n       = 50;
m       = 10;
o       = 100;
s       = 2;
b       = 1;

rng(10)

XData   = (1:n)' + s.*(2.*(randn(n,1) - 0.5));
YData   = 3.*XData - 2  + 5.*s.*(2.*(randn(n,1) - 0.5));
ZData   = -0.2.*XData + 5  + s.*(2.*(randn(n,1) - 0.5));

[func,linCoeff] = fitLinear([XData,YData],ZData);
[XDataFit,YDataFit]        = ndgrid(linspace(min(XData),max(XData),o),linspace(min(YData),max(YData),o));
ZDataFit        = func([XDataFit(:),YDataFit(:)]);

b       = 10;
[func2,linCoeff2] = fitLinear([XData,YData],ZData);
XDataFit2        = linspace(min(XData) - b,max(XData) + b,m)';
YDataFit2        = linspace(min(YData) - b,max(YData) + b,m)';
ZDataFit2        = func2([XDataFit2,YDataFit2]);


figure(1)
clf

scatter3(XData,YData,ZData,...
    'Marker',           '.',...
    'MarkerEdgeColor',  'k')
hold on

plot3(XDataFit(:),YDataFit(:),ZDataFit,'-c')

plot3(XDataFit2,YDataFit2,ZDataFit2,'-or')

