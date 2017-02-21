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

function [ vehicleCorr ] = CalcVehicleCorr( x, CorrMat, range, decay)
%CALCVEHICLECORR 
%
% berechnung der Korrelation des Vehikels zu den Landmarken in abhängigkeit
% einer Exponentialfunktion
%
%   INPUT:
%   x: karte
%   CorrMat:    Korrelationsmatrix
%   range:      Landmarken in Umkreis range
%   decay:      Faktor für die Exponentialfunktion


%calculate the distance to the Landmarks. 
xv=repmat(x(1:2),(size(x,1)-3)/2,1);
diff=(x(4:end)-xv);
diff=diff.^2;
distance(1:(size(x,1)-3)/2)=sqrt(diff(1:2:end)+diff(2:2:end))';
[D, I]=sort(distance);
%Take only landmarks with dist<=2*range
D=D(D<=2*range);
I=I(1:length(D));

Corr=[];

%exponential decay
D(:)=2*exp(-D(:)*decay);

for i=I
    Corr=[Corr mean([CorrMat(1,3+i) CorrMat(2,4+i)])];
end

if size(D)~=size(Corr)
    disp('hallo');
end
Corr=Corr.*D;

vehicleCorr=mean(Corr);


end

