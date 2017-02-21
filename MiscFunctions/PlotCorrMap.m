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
function PlotCorrMap( lm, wall, CorrMat, mapLimits)
%PLOTCORRMAP Summary of this function goes here
%   Detailed explanation goes here
%figure

clear all
% Load map and corresponding Plot Variables. 
% plot variables are created during a run of 
% ekfslam_sim. So in case of a new map or a missing
% plot variable file, just run SLEmotion with 
% data = ekfslam_sim(lm, wp, object, wall, oi, 0)
% and load map before.
% Plot variable file should be created in the 
% working directory.
load('CorrMap_PlotVariables.mat')
load('CorrMap_TestMap.mat')

close all

lm_xy = lm(1:2,:);
lm_xy = reshape(lm_xy,[2*size(lm,2),1]);


%Quantization steps
nq = 20;
%Subsampling with Factor (for higher accuracy)
scalingFactor = 2;
%Size of the Border (WrapAround) in m
wrapSize = 2 * scalingFactor;
%Radius of the Structured Element ball for dilation
dilateRadius = 2 * scalingFactor;

evalDistance = 1;

downgradeCorrFactor = 0.5;

% Plotting Colors for line plot
maxQ = max(CorrMat(CorrMat ~= 1));
cm = colormap(hot); % returns the current color map
colorFactor = 64 / maxQ;
%nq = 64 / maxQ;


%Filter Image?
switchFilter = 1;
filterSize = 2 * scalingFactor;
H = fspecial('disk',filterSize);


%Scale mapLimits, path and maxRange
mapLimits=round(mapLimits) * scalingFactor;

n_lm=(size(lm_xy,1))/2;


%% Transformation in BildKoordinaten

%Scaling of the points
lm_xy=lm_xy.*scalingFactor;

%Imagesize
xmin=mapLimits(1,1)-wrapSize;
xmax=mapLimits(2,1)+wrapSize;
ymin=mapLimits(1,2)-wrapSize;
ymax=mapLimits(2,2)+wrapSize;

%Transformation (lm_rc = ColumnRow)
lm_cr=round(lm_xy+repmat([-(xmin-1); -(ymax+1)], n_lm,1));
lm_cr(2:2:end)=-lm_cr(2:2:end);


%CorrGraph in the Image Space ImMat(row, column, q)
ImMat=zeros(ceil(ymax-ymin), ceil(xmax-xmin),nq);

%Draw only lines in specified distance. Higher correlated landmarks must stay
%closer
MAX_RANGE = 6.0;
dMH = MAX_RANGE*5;
dML = MAX_RANGE;
corrDistance=(dMH:-(dMH-dML)/(nq-1):dML);



%% Draw images
for i=1:2:size(lm_cr,1)
    for j=i+2:2:size(lm_cr,1)
        
        %calculate quantizationstep
        q=round(CorrMat((i+1)/2,(j+1)/2)*nq);
        lmDistance=sqrt((lm_xy(i)-lm_xy(j))^2+(lm_xy(i+1)-lm_xy(j+1))^2)/scalingFactor;
        
        
        if evalDistance
            if lmDistance>corrDistance(max(q,1))
                q=round(q * downgradeCorrFactor);
            end
        end
        
        
        if q~=0 && (lmDistance<corrDistance(max(q,1)) || ~evalDistance)
            
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
            
           % [JF 2016] Does currently not work as expected, there are some 
           % scaling issues. 
%                 qPlot = round(CorrMat((i+1)/2,(j+1)/2)*colorFactor);
%                 line(points(1:2:end)/scalingFactor, ymax - points(2:2:end)/scalingFactor, ... 
%                     'Color', cm(65 - qPlot,:), 'LineWidth', 2)
%                 hold on
            %write to the Matrix (Image)
            for imat=1:size(row,2)
                ImMat(row(imat),col(imat),q)=1;
            end
            
        end
    end
end


%% Image Processing

CorrMap_ImSpace=zeros(size(ImMat,1), size(ImMat,2));

for i=1:nq
    actualIm=ImMat(:,:,i);
    
    %dilate and fill holes
    SE=strel('ball', dilateRadius, 0, 0);
    filledIm=imfill(imdilate(actualIm,SE), 'holes');
    
    %overlapp the images
    CorrMap_ImSpace(filledIm==1)=i/(nq);
    
end

[X,Y]=meshgrid(xmin:xmax-1, ymin:ymax-1);
X=X/scalingFactor;
Y=Y/scalingFactor;

if switchFilter==1
    H = fspecial('disk',filterSize);
    %filter
    CorrMap_ImSpace=imfilter(CorrMap_ImSpace,H,'replicate');
end

CorrMap=flipud(CorrMap_ImSpace);

wallHeight = max(max(CorrMap)) + 0.1;

%figure

hCorrMap=surf(X,Y,1-CorrMap);
xlabel('x', 'fontsize', 14, 'fontweight', 'bold');
ylabel('y', 'fontsize', 14, 'fontweight', 'bold');
% title('Security map', 'fontsize', 14, 'fontweight', 'bold')
view(2);
caxis([-1 1])
axis equal
% shading interp

hold on

% Plot Walls
if size(wall(1).x,2)==0
    wall(1)=[];
end
%plot walls and lm
wallArea=[0, 0, 0, 0]; %[xmin xmax ymin ymax]
for i=1:size(wall,2)
    if size(wall(i).x,2)==1
        plot3(wall(i).x(1,1), wall(i).x(2,1),10,'o','Linewidth', 2,'Markersize',2, 'color', 'black')
    else
        h.wall=line(wall(i).x(1,:),wall(i).x(2,:),wallHeight*ones(size(wall(i).x(1,:))) ,'LineWidth',4, 'Color', 'black');  
    end
    wallArea=[min([wallArea(1) min(wall(i).x(1,:))]), max([wallArea(2) max(wall(i).x(1,:))]), ...
        min([wallArea(3) min(wall(i).x(2,:))]), max([wallArea(4) max(wall(i).x(2,:))])];
end
h.lm=plot3(lm(1,:),lm(2,:), wallHeight*ones(size(lm(1,:))),'ok', 'MarkerFaceColor', [0,0,0]);

xlim(wallArea(1:2))
ylim(wallArea(3:4))

ax = gca;
ax.XTick = wallArea(1):2:wallArea(2);
ax.YTick = wallArea(3):2:wallArea(4);

set(gcf, 'PaperPosition', [-1.0 -0.1 7.0 7.1]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 7]); %Set the paper to have width 5 and height 5.
saveas(gcf, ['CorrMap_interp', datestr(now, 'HHmmss')], 'pdf')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot unquantisized version of line corr plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure

lm_xy = lm(1:2,:);
lm_xy = reshape(lm_xy,[2*size(lm,2),1]);

lm_cr = lm_xy;

scalingFactor = 1;

maxQ = max(CorrMat(CorrMat ~= 1));

nq = 64 / maxQ;

cm = colormap(hot); % returns the current color map

%% Draw images    
for i=1:2:size(lm_xy,1)
        for j=i+2:2:size(lm_xy,1)
            
            %calculate quantizationstep
            q=round(CorrMat((i+1)/2,(j+1)/2)*nq);           
            lmDistance=sqrt((lm_xy(i)-lm_xy(j))^2+(lm_xy(i+1)-lm_xy(j+1))^2)/scalingFactor;
             
           
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

                line(points(1:2:end),points(2:2:end), 'Color', cm(65-q, :), ...
                    'LineWidth', 2)
                hold on

            end
        end
    end

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
% h.lm=plot(lm(1,:),lm(2,:),'b*');

xlim(wallArea(1:2))
ylim(wallArea(3:4))

caxis([-1 1])
axis equal

ax = gca;
ax.XTick = wallArea(1):2:wallArea(2);
ax.YTick = wallArea(3):2:wallArea(4);
axis tight

xlabel('x', 'fontsize', 14, 'fontweight', 'bold');
ylabel('y', 'fontsize', 14, 'fontweight', 'bold');


hold off

set(gcf, 'PaperPosition', [-1.0 -0.1 7.0 7.1]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 7]); %Set the paper to have width 5 and height 5.
saveas(gcf, ['CorrMap_lines', datestr(now, 'HHmmss')], 'pdf')


end

