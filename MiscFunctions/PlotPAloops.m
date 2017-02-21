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
function [ output_args ] = PlotPAloops( movieName, n )
%PLOTPALOOPS 
%
%   Plot der Schleifen im PA-raum für ein gespeichertes Szenario mit moviename
%

load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName '\data.mat']);


p=data.SLEmotion.PA.p;
a=data.SLEmotion.PA.a;

% mean(p)
% mean(a)

xData=(0:length(p)-1).*(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl);

h.fig1=figure(n);
clf(h.fig1);
set(h.fig1, 'name', 'PA loop', 'Units', 'Normalized', 'OuterPosition', [0 0.4 0.2 0.5]);
hold on
axis equal
axis([-0.5 0.8 -1 1])

xlabel('Gefallen', 'fontsize', 18, 'fontweight', 'bold');
ylabel('Erregung', 'fontsize', 18, 'fontweight', 'bold');

h.Xachse=line([-1,1], [0,0], 'linewidth', 1, 'color', 'k');
h.Yachse=line([0,0], [-1,1], 'linewidth', 1, 'color','k');

% h.P=text(0.77,-0.03, 'Gefallen', 'fontsize', 11);
% h.A=text(0.03,0.72, 'Erregung', 'fontsize', 11, 'Rotation',90);

name='EH';

%E
iS=round(55 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iE=round(75 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iD=iE-iS;
for i=iS:1:iE
    col=[(iE-i)/iD (iE-i)/iD (iE-i)/iD];
    h.E=plot(p(i), a(i), 'ok', 'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',col');

end

%F
iS=round(116 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iE=round(127 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iD=iE-iS;
for i=iS:1:iE
    col=[1 (iE-i)/iD (iE-i)/iD];
    h.F=plot(p(i), a(i), 'ok', 'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',col');
end


%G
iS=round(135 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iE=round(145 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iD=iE-iS;
for i=iS:1:iE
    col=[(iE-i)/iD 1 (iE-i)/iD];
    h.G=plot(p(i), a(i), 'ok', 'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',col');
end

%H
iS=round(202 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iE=round(225 /(data.SLEmotion.parameterSetup.dtObserve+data.SLEmotion.parameterSetup.dtControl));
iD=iE-iS;
for i=iS:1:iE
    col=[(iE-i)/iD (iE-i)/iD 1];
    h.H=plot(p(i), a(i), 'ok', 'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',col');
end

%h.Ll=legend([h.E h.F h.G h.H], 'Positiver Belohnungszyklus', 'Reaktion auf Gefahr', ...
%    'Vermeidung von Gefahr', 'Negativer Belohnungszyklus', 'fontsize', 12);

set(gca, 'Ytick', [-1:0.5:1], 'XTick', [-1:0.5:1]);

set(gca,'FontSize',18);

ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

print(h.fig1,'-dpdf','-r600', ['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Vortrag\' movieName '\PAloops' name '.pdf']); 


end

