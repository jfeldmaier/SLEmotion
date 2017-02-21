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

function [ Corr ] = CalcCorrMatrix( Cov )
%CALCKORRMATRIX Berechnung der Korrelationsmatrix aus der Normierung der
%Kovarianzmatrix
    
len=size(Cov,1);
tCorr=zeros(len,len);

for i=1:len
    for j=i:len
        tCorr(i,j)=Cov(i,j)/sqrt(Cov(i,i)*Cov(j,j));
    end
end

Corr=tCorr+tCorr'-diag(diag(tCorr));

end

