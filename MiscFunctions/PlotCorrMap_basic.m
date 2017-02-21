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
function PlotCorrMap( lm, wall, CorrMat)
%PLOTCORRMAP Summary of this function goes here
%   Detailed explanation goes here


figure

lm_xy = lm(1:2,:);
lm_xy = reshape(lm_xy,[2*size(lm,2),1]);

n_lm=(size(lm_xy,1))/2;

%Transformation (lm_rc = ColumnRow)
% lm_cr=round(lm_xy+repmat([-(xmin-1); -(ymax+1)], n_lm,1));
% lm_cr(2:2:end)=-lm_cr(2:2:end);
lm_cr = lm_xy;

nq = 20;
scalingFactor = 1;
evalDistance = 1;

maxQ = max(CorrMat(CorrMat ~= 1));

nq = 64 / maxQ;

%% Draw images    
for i=1:2:size(lm_xy,1)
        for j=i+2:2:size(lm_xy,1)
            
            %calculate quantizationstep
            q=round(CorrMat((i+1)/2,(j+1)/2)*nq);           
            lmDistance=sqrt((lm_xy(i)-lm_xy(j))^2+(lm_xy(i+1)-lm_xy(j+1))^2)/scalingFactor;
            
            
%             if parameterSetup.Maps.evalDistance
%                 if lmDistance>corrDistance(max(q,1))
%                     q=round(q*parameterSetup.Maps.downgradeCorrFactor);
%                 end 
%             end
                        
           
            if q~=0 %&& (lmDistance<corrDistance(max(q,1)) || ~parameterSetup.Maps.evalDistance)

                dcol=lm_cr(j)-lm_cr(i);
                drow=lm_cr(j+1)-lm_cr(i+1);
                
                %draw the lines
                if drow==0 && dcol==0
                    col=lm_cr(i);
                    row=lm_cr(i+1);                    
                else
                    if abs(drow)>=abs(dcol)
                        %sort the points to get first point over second point
                        points=[lm_cr(i),lm_cr(j); lm_cr(i+1), lm_cr(j+1)]; 
                        [~,s_idx]=sort(points(2,:));
                        points=points(:,s_idx);                

                        %calc the lines
                        row=points(2,1):points(2,2);
                        if points(1,1)<=points(1,2)
                            col=repmat(points(1,1),1,size(row,2))+round([0:size(row,2)-1].*abs(dcol)/abs(drow));                   
                        else
                            col=repmat(points(1,1),1,size(row,2))-round([0:size(row,2)-1].*abs(dcol)/abs(drow));                    
                        end
                    else
                        %sort points to get first point left of second point
                        points=[lm_cr(i),lm_cr(j); lm_cr(i+1), lm_cr(j+1)]; 
                        [~,s_idx]=sort(points(1,:));
                        points=points(:,s_idx); 

                        %calc the lines
                        col=points(1,1):points(1,2);
                        if points(2,1)<=points(2,2)
                            row=repmat(points(2,1),1,size(col,2))+round([0:size(col,2)-1].*abs(drow)/abs(dcol));                   
                        else
                            row=repmat(points(2,1),1,size(col,2))-round([0:size(col,2)-1].*abs(drow)/abs(dcol));                    
                        end
                    end
                end
                
                cm = colormap(hot); % returns the current color map
                line(points(1:2:end),points(2:2:end), 'Color', cm(65-q, :), ...
                    'LineWidth', 2)
                hold on
                    
%                 %write to the Matrix (Image)
%                 for imat=1:size(row,2)
%                     ImMat(row(imat),col(imat),q)=1;
%                 end

            end
        end
    end



xMax = round(max(lm(1,:))+1);
yMax = round(max(lm(2,:))+1);
xMin = round(min(lm(1,:))-1);
yMin = round(min(lm(2,:))-1);








% h.CorrMap=surf(SLEmotion.MapX,SLEmotion.MapY,SLEmotion.SecurityMap);
% xlabel('x [m]', 'fontsize', 12, 'fontweight', 'bold');
% ylabel('y [m]', 'fontsize', 12, 'fontweight', 'bold');
% title('Security map', 'fontsize', 14, 'fontweight', 'bold')
% view(2);
% caxis([-1 1])
% axis equal
% shading interp

scatter(lm(1,:), lm(2,:), 'ok', 'Filled')

% Plot Walls
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

xlim(wallArea(1:2))
ylim(wallArea(3:4))
% axis equal

ax = gca;
ax.XTick = wallArea(1):1:wallArea(2);
ax.YTick = wallArea(3):2:wallArea(4);

xlabel('x', 'fontsize', 12, 'fontweight', 'bold');
ylabel('y', 'fontsize', 12, 'fontweight', 'bold');
% title('Correlation Map', 'fontsize', 14, 'fontweight', 'bold')

% Plot path
% h.CorrMapPath=plot3(0,0,1, 'wo', 'MarkerFaceColor', [1 1 1], 'markersize', 1, 'parent', h.spCorrMap);

hold off

set(gcf, 'PaperPosition', [-1.0 -0.1 3.0 7.1]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 7]); %Set the paper to have width 5 and height 5.
saveas(gcf, ['CorrMap_lines', datestr(now, 'HHmmss')], 'pdf')


end

