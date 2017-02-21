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

function [ ActualPositionCorr ] = CalcActualPositionCorr( lm_xy, X,Y,Z )
%CALCACTUALPOSITIONCORR Berechnet die aktuelle Korrelation auf Basis der
%CorrMap
%
%   INPUT:
%   lm_xy:  landmarkpositionen
%   X,Y,Z:  meshgrid der CorrMap
%
%
%   OUTPUT:
%   ActualPositionCorr: Korrelation an aktueller Position


    if size(lm_xy,1)<=3 || isempty(X)
        ActualPositionCorr=0;
    else

        %Calculate Z(Correlation on current position) of the vehicle
        vehiclePos=lm_xy(1:2);   
        [~, colID] = min(abs(X(1,:) - vehiclePos(1)));
        [~, rowID] = min(abs(Y(:,1) - vehiclePos(2)));
        ActualPositionCorr=Z(rowID, colID);


    end
        
end

