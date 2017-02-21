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

function [X,Y, CorrMap, CorrMapPath, PathMap, PathMapNoTime, ImMat] = CalcCorrMap( CorrMat, XX, mapLimits, path, parameterSetup)
%CALCCORRMAP Berechnung der Korrelationsmatrix 
%
%   INPUTS:     
%   CorrMat: Korrelationsmatrix ohne vehicle Information, also Mat(4:end, 4:end)
%            bereits gemittelt über KorrXX, KorrYY
%
%   XX:   KArte
%   mapLimits:  KartenGröße
%   path:   Weg
%
%   OUTPUT:
%   X,Y  Meshgrid X,Y entsprechen metrischen Koordinaten, 
%   CorrMap         Normale CorrMap
%   CorrMapPath     CorrMap gewichtet mit Path
%   PathMap
%   PathMap         pathMap ohne Verblassen der Spur

    %% Preprocessing

    %Quantization steps
    nq=parameterSetup.Maps.nq;
    %Subsampling with Factor (for higher accuracy)
    scalingFactor=parameterSetup.Maps.scalingFactor;
    %Size of the Border (WrapAround) in m
    wrapSize=parameterSetup.Maps.wrapSize*scalingFactor;
    %Radius of the Structured Element ball for dilation  
    dilateRadius=parameterSetup.Maps.dilateRadiusCorr*scalingFactor;
   
    %Filter Image?
    switchFilter=parameterSetup.Maps.switchFilterCorr;
    filterSize=parameterSetup.Maps.filterSizeCorr*scalingFactor;
    H = fspecial('disk',filterSize);  
    

    %Calculate the Pathmap (Pheromonspur? [JF])
    [~,~,PathMap, PathMapNoTime]=CalcPathMap(path, mapLimits, parameterSetup);
    
    %Scale mapLimits, path and maxRange
    mapLimits=round(mapLimits)*scalingFactor;
  
    
    lm_xy=XX(4:end);
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
    dMH=parameterSetup.Maps.dMaxHigh;
    dML=parameterSetup.Maps.dMaxLow;
    corrDistance=(dMH:-(dMH-dML)/(nq-1):dML);

  
    
    %% Draw images    
    for i=1:2:size(lm_cr,1)
        for j=i+2:2:size(lm_cr,1)

            %calculate quantizationstep
            q=round(CorrMat((i+1)/2,(j+1)/2)*nq);           
            lmDistance=sqrt((lm_xy(i)-lm_xy(j))^2+(lm_xy(i+1)-lm_xy(j+1))^2)/scalingFactor;
            
            
            if parameterSetup.Maps.evalDistance
                if lmDistance>corrDistance(max(q,1))
                    q=round(q*parameterSetup.Maps.downgradeCorrFactor);
                end 
            end
                        
           
            if q~=0 && (lmDistance<corrDistance(max(q,1)) || ~parameterSetup.Maps.evalDistance)

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
                    
                %write to the Matrix (Image)
                for imat=1:size(row,2)
                    ImMat(row(imat),col(imat),q)=1;
                end

            end
        end
    end

    save('CorrMap_PlotVariables.mat','CorrMat','mapLimits')

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
    
    %flip the map
    CorrMapPath=flipud(CorrMap_ImSpace.*flipud(PathMapNoTime));
    CorrMap=flipud(CorrMap_ImSpace);

    

end

