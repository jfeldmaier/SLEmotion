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
function PlotPAtimeline( movieName, n )
%PLOTPATIMELINE 
%
%   Plot der Timeline des PA-Space für eine Szenario mit Moviename
%

load(['Movies/' movieName '/data.mat']);


p=data.SLEmotion.PA.p;
a=data.SLEmotion.PA.a;

mean(p);
mean(a);

h.fig1=figure(n);
clf(h.fig1);
set(h.fig1, 'name', 'PA timeline', 'Units', 'Normalized', 'OuterPosition', [0 0.4 0.2 0.5]);
hold on

xData=(0:length(p)-1).*(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl);

%A
minR=0;
maxR=39;
name='A';

% minR=10;
% maxR=50;
% name='B';

% minR=65;
% maxR=105;
% name='C';

% minR=136;
% maxR=176;
% name='D';

plotRange=find(xData>=minR-0.1 & xData<=minR+0.1):find(xData>=maxR-0.1 & xData<=maxR+0.1);


% % %Breiche S1
h.fA=fill([1 1 15 15],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.15); 
% h.tA=text(7,0.8,'A', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fB=fill([20 20 37 37],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.15); 
% h.tB=text(28,0.8,'B', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fC=fill([75 75 95 95],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.15); 
% h.tC=text(83,0.8,'C', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fD=fill([146 146 165 165],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.15); 
% h.tD=text(155,0.8,'D', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% 
% %Bereiche E F G H
% h.fE=fill([55 55 73 73],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25); 
% h.tE=text(63,0.8,'E', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fF=fill([110 110 127 127],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25); 
% h.tF=text(118,0.8,'F', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fG=fill([128 128 145 145],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25); 
% h.tG=text(135,0.8,'G', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);
% h.fH=fill([205 205 225 225],[-1 1 1 -1],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25); 
% h.tH=text(213,0.8,'H', 'fontweight', 'bold', 'fontsize', 16, 'color', [0.2 0.2 0.2]);


h.PAtimelineP=line(xData(plotRange), p(plotRange),'color', 'r', 'linewidth', 2);
h.PAtimelineA=line(xData(plotRange), a(plotRange),'color', 'b', 'linewidth', 2);

axis([minR, maxR, -1, 1]);


xlabel('Zeit [s]', 'fontsize', 14, 'fontweight', 'bold');
ylabel('Gefallen / Erregung', 'fontsize', 14, 'fontweight', 'bold');

set(gca,'XTick',[0:10:maxR], 'YTick', [-1 -0.5 0 0.5 1]);


%legend(h.f,'hide')

h.legend=legend([h.PAtimelineP, h.PAtimelineA], 'Gefallen', 'Erregung');
set(h.legend,'FontSize',14, 'location', 'southeast');

set(gca,'FontSize',14);

ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

print(h.fig1,'-dpdf','-r1200', ['Vortrag/' movieName '/PAtimeline' name '.pdf']); 


end

