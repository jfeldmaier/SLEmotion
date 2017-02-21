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

function [X,Y, PathMap, PathMapNoTime] = CalcPathMap( path, mapLimits, parameterSetup)
%CALCCORRMAP berechnung der PathMap
%
%   INPUTS:     
%   path: position des vehikels pro Zeitschritt
%
%   mapLimits: die Grenzen der bisher befahrenen/gesehenen Karte
%
%   parameterSetup: ....
%
%   OUTPUT:
%   X,Y,PathMap:  Meshgrid. X,Y entsprechen metrischen Koordinaten, PathMap
%   dem gefahrenen Weg des Vehikels [0..1]

    %% Preprocessing

    %Subsampling with Factor
    scalingFactor=parameterSetup.Maps.scalingFactor;
    %Size of the Border (WrapAround) in m
    wrapSize=parameterSetup.Maps.wrapSize*scalingFactor;
    %maximum Observing Range
    maxRange=parameterSetup.maxRange*scalingFactor;
    %Radius of the Structured Element ball for dilation  
    dilateRadius=parameterSetup.Maps.dilateRadiusPath*scalingFactor;   
    %Create Filter
    filterSize=parameterSetup.Maps.filterSizePath*scalingFactor;
    H = fspecial('disk',filterSize);  
       

    
    %Scale mapLimits, path
    mapLimits=round(mapLimits)*scalingFactor;
    path=[[0;0;0], path(1:3,path(1,:)~=0)];
    path(1:2,:)=path(1:2,:).*scalingFactor;
    

    %Imagesize
    xmin=mapLimits(1,1)-wrapSize;
    xmax=mapLimits(2,1)+wrapSize;
    ymin=mapLimits(1,2)-wrapSize;
    ymax=mapLimits(2,2)+wrapSize;    


    %die Familiarität am aktuellen Punkt soll 0 sein, dh der Weg wird bis
    %zu dem punkt gelöscht, wo die zurückgelegte Distanz kleiner ist als
    %die dilatierung und filterunge ihn erweitern
    dist=0;
    j=size(path,2);
    pathCut=path;
    while dist<dilateRadius+filterSize+1 && j>=1
        dist=dist+sqrt((pathCut(1,j)-pathCut(1,max(1,j-1)))^2+(pathCut(2,j)-pathCut(2,max(1,j-1)))^2);
        pathCut(:,j)=[];
        j=j-1;       
    end
    
    %add past time to path and quantize
    l=size(pathCut,2);
    pathCut(3,:)=0;
    for i=l:-1:1
        pathCut(3,i)=(l-i)*parameterSetup.dtControl;
    end   
    pathCut(3,:)=round(pathCut(3,:)*10)/10;
    
    %transformation of path into img_coordinates
    pathCut(1,:)=pathCut(1,:)-(xmin-1);
    pathCut(2,:)=-((pathCut(2,:)-(ymax+1)));
    %path=unique(round(path)','rows')';
    
    pathCut(1:2,:)=round(pathCut(1:2,:));
    
    %Doppelte Punkte, welche zeitlich hintereinander auftreten aussortiern.
    %Zeitlich versetzte behalten.
    i=1;
    pathTime=[];
    while i<size(pathCut,2)-1
        pathTime=[pathTime pathCut(:,min(length(pathCut),i))];
       
        while pathCut(1,i)==pathCut(1,i+1) && pathCut(2,i)==pathCut(2,i+1) && i<size(pathCut,2)-2
            i=i+1;
        end

        i=i+1;
    end

    
    %calc the Value of the Path depending on the past time. (Exponential decay)
    if ~isempty(pathTime)
        pathTime(3,:)=min(1,exp(-(pathTime(3,:)/parameterSetup.Maps.pathDecayFactor)));
    end
    
    %draw Path as Image
    PathMap=zeros(ceil(ymax-ymin), ceil(xmax-xmin),1);
    PathMapNoTime=zeros(size(PathMap));
    for ii=1:size(pathTime,2)
        PathMap(pathTime(2,ii), pathTime(1,ii))=min(1,PathMap(pathTime(2,ii), pathTime(1,ii))+pathTime(3,ii));
        PathMapNoTime(pathTime(2,ii), pathTime(1,ii))=1;
    end

    save('PathMapAusarbeitung.mat', 'PathMapNoTime');
    
    %dilate and filter Pathmap
    SE=strel('disk', dilateRadius);
    PathMap=imdilate(PathMap,SE);  
    PathMap=imfilter(PathMap,H,'replicate');
    PathMapNoTime=imdilate(PathMapNoTime,SE);  
    PathMapNoTime=imfilter(PathMapNoTime,H,'replicate');    
       
    save('PathMapAusarbeitung.mat', 'PathMap', '-append')
    
    %create meshgrid
    [X,Y]=meshgrid(xmin:xmax-1, ymin:ymax-1);
    X=X/scalingFactor;
    Y=Y/scalingFactor;
    
    %flip the map
    PathMap=flipud(PathMap);
    PathMapNoTime=flipud(PathMapNoTime);
    
    

end

