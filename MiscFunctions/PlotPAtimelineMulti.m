% 
% Created on Apr 1, 2014
% @author: Martin Stimpfl
% @author: Johannes Feldmaier <johannes.feldmaier@tum.de>
%     Copyright (C) 2014  Johannes Feldmaier
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
function PlotPAtimelineMulti( movieName, n )
%PLOTPATIMELINE %
%
%   Plot mehrerer Zeitverläufe
%
%   INPUT:
%   movieName: Struct mit namen der Movies


d1=load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName{1} '\data.mat']);
d2=load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName{2} '\data.mat']);
d3=load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName{3} '\data.mat']);
d4=load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName{4} '\data.mat']);

p1=d1.data.SLEmotion.PA.p;
a1=d1.data.SLEmotion.PA.a;

p2=d2.data.SLEmotion.PA.p;
a2=d2.data.SLEmotion.PA.a;

p3=d3.data.SLEmotion.PA.p;
a3=d3.data.SLEmotion.PA.a;

p4=d4.data.SLEmotion.PA.p;
a4=d4.data.SLEmotion.PA.a;


mean(p1)
mean(a1)
mean(p2)
mean(a2)
mean(p3)
mean(a3)
mean(p4)
mean(a4)


h.fig1=figure(n);
clf(h.fig1);
set(h.fig1, 'name', 'PA timeline', 'Units', 'Normalized', 'OuterPosition', [0 0.4 0.5 0.4]);
hold on

xData=(0:length(p1)-1).*(d1.data.SLEmotion.parameterSetup.dtObserve+d1.data.SLEmotion.parameterSetup.dtControl);


%h.PAtimelineA1=line(xData(1:round(end)), a1(1:round(end)),'color', [0 73 119]./255, 'linewidth', 2);
h.PAtimelineP1=line(xData(1:round(end)), p1(1:round(end)),'color', [119 0 5]./255, 'linewidth', 2);

%h.PAtimelineA2=line(xData(1:round(end)), a2(1:round(end)),'color', [0 127 206]./255, 'linewidth', 2);
h.PAtimelineP2=line(xData(1:round(end)), p2(1:round(end)),'color', [206 0 10]./255, 'linewidth', 2);

%h.PAtimelineA3=line(xData(1:round(end)), a3(1:round(end)),'color', [79 188 255]./255, 'linewidth', 2);
h.PAtimelineP3=line(xData(1:round(end)), p3(1:round(end)),'color', [255 87 95]./255, 'linewidth', 2);

%h.PAtimelineA4=line(xData(1:round(end)), a4(1:round(end)),'color', [155 217 255]./255, 'linewidth', 2);
h.PAtimelineP4=line(xData(1:round(end)), p4(1:round(end)),'color', [255 193 196]./255, 'linewidth', 2);




axis([0, xData(round(end)), -1, 1]);


xlabel('Zeit [s]', 'fontsize', 16, 'fontweight', 'bold');
ylabel('Gefallen', 'fontsize', 16, 'fontweight', 'bold');

set(gca,'XTick',[0:50:xData(end)]);

set(gca,'FontSize',16);

%legend(h.f,'hide')

h.legend=legend([h.PAtimelineP1,  h.PAtimelineP2,  h.PAtimelineP3, h.PAtimelineP4], ...
    'S1',  'S2',  'S3', 'S4');
set(h.legend,'FontSize',18, 'location', 'southeast');


ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

print(h.fig1,'-dpdf','-r1200', ['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Vortrag\PAtimeline_S14_P.pdf']); 


end

