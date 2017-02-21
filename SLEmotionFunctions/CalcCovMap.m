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

function [ X,Y, CovMap ] = CalcCovMap( path, cov, mapLimits, parameterSetup )
%CALCCOVMAP Calculate a Map with experienced normed Covariance of the Vehicle
%   INPUTS:     
%   path: position des vehikels pro Zeitschritt
%   cov: vehicle-covariance
%   mapLimits: die Grenzen der bisher befahrenen/gesehenen Karte
%
%   parameterSetup: ....
%
%   OUTPUT:
%   X,Y,CovMap:  Meshgrid. X,Y entsprechen metrischen Koordinaten, CovMap [0 1]
%

    %% Preprocessing

    %Subsampling with Factor
    scalingFactor=parameterSetup.Maps.scalingFactor;
    %Size of the Border (WrapAround) in m
    wrapSize=parameterSetup.Maps.wrapSize*scalingFactor;
    %Radius of the Structured Element ball for dilation  
    dilateRadius=parameterSetup.Maps.dilateRadiusCov*scalingFactor;   
    %Create Filter
    filterSize=parameterSetup.Maps.filterSizePath*scalingFactor;
    H = fspecial('disk',filterSize);  
       

    
    
    %Scale mapLimits, path
    mapLimits=round(mapLimits)*scalingFactor;
    path=[[0;0;0], path(1:3,path(1,:)~=0)];
    %cov comes every dt
    dt=(parameterSetup.dtObserve/parameterSetup.dtControl)+1;
    path=path(1:2,dt:dt:end);
    path(1:2,:)=path(1:2,:).*scalingFactor;
    
    %normalize, lowest values -> 1, highest ->-1
    path(3,:)=1-2*cov;
    
    
    %Imagesize
    xmin=mapLimits(1,1)-wrapSize;
    xmax=mapLimits(2,1)+wrapSize;
    ymin=mapLimits(1,2)-wrapSize;
    ymax=mapLimits(2,2)+wrapSize;

   

    %transformation of path into img_coordinates
    path(1,:)=path(1,:)-(xmin-1);
    path(2,:)=-((path(2,:)-(ymax+1)));
    path(1:2,:)=round(path(1:2,:));
    path=unique(path','rows', 'last')';
    
    

    %covNorm(covNorm<0)=0;
    
    
    %draw Path as Image
    CovMap=-ones(ceil(ymax-ymin), ceil(xmax-xmin),1);
    for ii=1:size(path,2)
        CovMap(path(2,ii), path(1,ii))=path(3,ii);
    end

    
    %dilate and filter Covmap
    SE=strel('disk', dilateRadius);
    CovMap=imdilate(CovMap,SE);  
    CovMap=imfilter(CovMap,H,'replicate');
       
    %create meshgrid
    [X,Y]=meshgrid(xmin:xmax-1, ymin:ymax-1);
    X=X/scalingFactor;
    Y=Y/scalingFactor;
    
    %flip the map
    CovMap=flipud(CovMap);
    
    

end


