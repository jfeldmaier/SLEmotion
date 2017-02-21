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


function [ PredictedCorr ] = CalcPredictedCorr( CorrMapX, CorrMapY, CorrMapZ, vehicleX, V, G )
%CALCPREDICTEDCORR berechnung der prognostizierten Korrelation in Richtung
%phi+G und gewissem Abstand (distance) zum vehicle

distance=10*V;

predictedPos=[vehicleX(1)+distance*cos(vehicleX(3)+G); vehicleX(2)+distance*sin(vehicleX(3)+G)];

if size(CorrMapX,1)==0 || size(CorrMapY, 1)==0
    PredictedCorr=0;
else
    %Calculate Z(Correlation on predicted position) of the vehicle
    [~, colID] = min(abs(CorrMapX(1,:) - predictedPos(1)));
    [~, rowID] = min(abs(CorrMapY(:,1) - predictedPos(2)));
    PredictedCorr=CorrMapZ(rowID, colID);
end

end

