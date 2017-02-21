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
function PlotSlamMap_Vortrag( movieName )
%PLOTSLAMMAP 
%   Plot der SLAM-Karte eines gespeicherten Movies
%
%   

load(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Movies\' movieName '\data.mat']);

fig1Pos=[0 0.4 0.28 0.5];

X=data.SLEmotion.X;
P=data.SLEmotion.P;
path=data.SLEmotion.path(1:2,:);
path=[[0;0], path(1:2,path(1,:)~=0)];


plotLm=33;
pathMark=(205/0.025:225/0.025);



h.fig1=figure(1);
clf(h.fig1)
set(h.fig1, 'name', 'Groundtruth Map', 'Units', 'Normalized', 'OuterPosition', fig1Pos);
hold on
axis equal
xlabel('x [m]', 'fontsize', 18, 'fontweight', 'bold');
ylabel('y [m]', 'fontsize', 18, 'fontweight', 'bold');

%S1
h.fR1=fill([-11.8 -13 -4.7 -3.5],[-4 0.3 2.5 -2],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR2=fill([-0.5 -0.5 10 10],[2 9 9 2],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR3=fill([-1 -1 9.5 9.5],[9.2 15 15 9.2],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR4=fill([-13.5 -13.5 -4.5 -4.5],[8 14 14 8],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR5=fill([-4.5 -4.5 4.5 4.5],[18.5 25.5 25.5 18.5],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 
h.fR6=fill([5 5 14.5 14.5],[18.5 25.5 25.5 18.5],'blue','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.25, 'EdgeColor','None'); 


h.tR1=text(-9.5,-1,'R1', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR2=text(2,3.5,'R2', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR3=text(2,12,'R3', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR4=text(-10,12,'R4', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR5=text(1,22,'R5', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);
h.tR6=text(12,22,'R6', 'fontweight', 'bold', 'fontsize', 14, 'color', [0.2 0.2 0.2]);



lmX=X(4:2:end);
lmY=X(5:2:end);

nrLm=length(lmX);


h.lm=plot(lmX(1:plotLm), lmY(1:plotLm), 'b+', 'markersize', 10);
ocov=1:(length(data.SLEmotion.X));
ocov=[1,2,3,(1:plotLm*2)+3];
pfcov= make_feature_covariance_ellipses(X(ocov),P(ocov,ocov));
%pfcov=pfcov(:,1:2*plotLm);
h.lm_cov=plot(pfcov(1,:), pfcov(2,:), 'linewidth', 1);

pathMark=(55/0.025:73/0.025);
h.pathMarkE=plot(path(1,pathMark),path(2,pathMark),'k.','markersize',20);
pathMark=(110/0.025:127/0.025);
h.pathMarkF=plot(path(1,pathMark),path(2,pathMark),'r.','markersize',20);
pathMark=(128/0.025:145/0.025);
h.pathMarkG=plot(path(1,pathMark),path(2,pathMark),'g.','markersize',20);
pathMark=(205/0.025:225/0.025);
h.pathMarkH=plot(path(1,pathMark),path(2,pathMark),'b.','markersize',20);

h.path=plot(path(1,1:end),path(2,1:end),'k.','markersize',2); % vehicle path estimate



h.l=line([0 0], [0 0], 'Linewidth', 2, 'Color','k');
h.pmE=line([0 0], [0 0], 'Linewidth', 2, 'Color','k');
h.pmF=line([0 0], [0 0], 'Linewidth', 2, 'Color','r');
h.pmG=line([0 0], [0 0], 'Linewidth', 2, 'Color','g');
h.pmH=line([0 0], [0 0], 'Linewidth', 2, 'Color','b');


%text(path(1,1), path(2,1)+0.5, 'Start', 'color', 'k', 'fontsize', 11, 'fontweight', 'bold');
%text(path(1,end), path(2,end)+0.5, 'Ziel', 'color', 'k', 'fontsize', 11, 'fontweight', 'bold');

sp1_xlim=[min([min(X(4:2:end)) min(path(1,:))])-6 max([max(X(4:2:end)) max(path(1,:))])+2];
sp1_ylim=[min([min(X(5:2:end)) min(path(2,:))])-2 max([max(X(5:2:end)) max(path(2,:))])+2];

axis([sp1_xlim sp1_ylim])


h.leg=legend([h.lm h.lm_cov ], 'Landmarken', 'Fehlerellipsen');
set(h.leg, 'Fontsize', 18, 'Location', 'Northwest');

set(gca,'FontSize',18);
%set(gca, 'YTick', [0 10 20], 'XTick', [-10 0 10]);

ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');

set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

mkdir(['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Vortrag\' movieName '\']);
print(h.fig1,'-dpdf','-r600',['C:\Users\no98tey\Documents\MATLAB\Diplomarbeit\Vortrag\' movieName '\SlamMapEH.pdf']); 







function p= make_feature_covariance_ellipses(x,P)
% compute ellipses for plotting feature covariances
N= 10;
inc= 2*pi/N;
phi= 0:inc:2*pi;
circ= 2*[cos(phi); sin(phi)];

lenx= length(x);
lenf= (lenx-3)/2;
p= zeros (2, lenf*(N+2));

ctr= 1;
for i=1:lenf
    ii= ctr:(ctr+N+1);
    jj= 2+2*i; jj= jj:jj+1;
    
    p(:,ii)= make_ellipse(x(jj), P(jj,jj), circ);
    ctr= ctr+N+2;
end

function p= make_ellipse(x,P,circ)
% make a single 2-D ellipse 
r= sqrtm_2by2(P);
a= r*circ;
p(2,:)= [a(2,:)+x(2) NaN];
p(1,:)= [a(1,:)+x(1) NaN];
