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


function [ observationCov ] = CalcObservationCov( P, idf )
%CALCOBSERVATIONVAR Calculate the arithmetic mean observation Covariance.
%Area of the covariance ellipse as measure

observationCov=0;
n=size(idf,2);

if n>=1
    for i=1:n
        observationCov=observationCov+CalcCovEllipseArea(P(idf(i)*2+2:idf(i)*2+3,idf(i)*2+2:idf(i)*2+3));
    end

    %Arithmetic mean
    observationCov=observationCov/n;
else
    observationCov=NaN;
end


end

