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

% This function shows the landmark density calculation and 
% the conduciveness calculation

maxRange = 10;
lmDensityFactor = 5;

lmCoords = [1, 1;
            2, 3;
            5, 1;
            2, 2;
            6, 7; ];

scatter(lmCoords(:,1), lmCoords(:,2));
hold on

testLM = [1, 7.0];
scatter(testLM(:,1), testLM(:,2), 'rx');

posMat = repmat(testLM, (length(lmCoords)),1);
diffMat = (posMat-lmCoords).^2;

distMat=sqrt(diffMat(1:2:end)+diffMat(2:2:end));

distMat = sort(distMat);
distMat = distMat(distMat<=maxRange);

density = sum(exp(-distMat/lmDensityFactor))

hold off