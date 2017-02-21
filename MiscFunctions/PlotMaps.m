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
function PlotMaps( lm, wp, object, wall, oi, data )
%PLOTMAPS 
% Plots the Groundtruthmap
%
%   


fig1Pos=[0 0.4 0.28 0.51];


h.fig1=figure(1);
clf(h.fig1)
set(h.fig1, 'name', 'Groundtruth Map', 'Units', 'Normalized', 'OuterPosition', fig1Pos);


%h.GroundtruthMap=subplot(spSet.size(1),spSet.size(2),spSet.GroundtruthMapNr, 'parent', h.fig1);
xlabel('x [m]', 'fontsize', 14, 'fontweight', 'bold');
ylabel('y [m]', 'fontsize', 14, 'fontweight', 'bold');
%title('Groundtruth', 'fontsize', 14, 'fontweight', 'bold', 'FontName', 'Verdana');
axis equal
hold on


%Breiche S1
h.fR1=fill([-13 -13 -4 -4],[-2 2 2 -2],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR2=fill([0 0 10 10],[2 9 9 2],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR3=fill([0 0 10 10],[9 15 15 9],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR4=fill([-13 -13 -4 -4],[9 15 15 9],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR5=fill([-4 -4 5 5],[19 26 26 19],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR6=fill([5 5 15 15],[19 26 26 19],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 


h.tR1=text(-10,0,'R1', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR2=text(2,3.5,'R2', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR3=text(2,12,'R3', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR4=text(-10,12,'R4', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR5=text(1,22,'R5', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR6=text(12,22,'R6', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);



if size(wall(1).x,2)==0
    wall(1)=[];
end
%plot walls and lm
wallArea=[0, 0, 0, 0]; %[xmin xmax ymin ymax]
for i=1:size(wall,2)
    if size(wall(i).x,2)==1
        plot(wall(i).x(1,1), wall(i).x(2,1),'o','Linewidth', 2,'Markersize',2, 'color', 'black')
    else
        h.wall=line(wall(i).x(1,:),wall(i).x(2,:) ,'LineWidth',4, 'Color', 'black');  
    end
    wallArea=[min([wallArea(1) min(wall(i).x(1,:))]), max([wallArea(2) max(wall(i).x(1,:))]), ...
        min([wallArea(3) min(wall(i).x(2,:))]), max([wallArea(4) max(wall(i).x(2,:))])];
end
h.lm=plot(lm(1,:),lm(2,:),'b*');
h.wp=plot(wp(1,:),wp(2,:), 'g', wp(1,:),wp(2,:),'g.', 'linewidth', 2);

set(h.wp, 'color', 'g');

text(wp(1,1), wp(2,1)+0.5, 'Start', 'color', 'g', 'fontsize', 14, 'fontweight', 'bold');
text(wp(1,end), wp(2,end)+1, 'Ziel', 'color', [1 0 0], 'fontsize', 14, 'fontweight', 'bold');


% sp1_xlim=[min([min(lm(1,:)) min(wp(1,:)) wallArea(1)])-2 max([max(lm(1,:)) max(wp(1,:)) wallArea(2)])+2];
% sp1_ylim=[min([min(lm(2,:)) min(wp(2,:)) wallArea(3)])-2 max([max(lm(2,:)) max(wp(2,:)) wallArea(4)])+2];

sp1_xlim=[min([ min(wp(1,:)) wallArea(1)])-2 max([ max(wp(1,:)) wallArea(2)])+2];
sp1_ylim=[min([ min(wp(2,:)) wallArea(3)])-2 max([ max(wp(2,:)) wallArea(4)])+2];

axis([sp1_xlim sp1_ylim])




h.leg=legend([h.wall h.lm h.wp(1)], 'Wände', 'Landmarken', 'Trajektorie');
set(h.leg, 'Fontsize', 14, 'location', 'NorthWest');

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

   
print(h.fig1,'-dpdf','-r1200',['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Vortrag\ExpMap.pdf']); 


end

