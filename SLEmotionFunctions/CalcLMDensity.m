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

function [ density ] = CalcLMDensity( XX, pos, parameterSetup )
%CALCLMDENSITY Berechnung der Landmarkendichte an Punkt pos
%   Als Maﬂ wird die Exponentialfunktion mit euklidischer Distanz zu allen
%   landmarks verwendet.


if size(pos,2)==2
    pos=pos';
end

posMat=repmat(pos, (length(XX))/2,1);

diffMat=(posMat-XX).^2;

distMat=sqrt(diffMat(1:2:end)+diffMat(2:2:end));

distMat=sort(distMat);
distMat=distMat(distMat<=parameterSetup.maxRange);

density=sum(exp(-distMat/parameterSetup.lmDensityFactor));

end

