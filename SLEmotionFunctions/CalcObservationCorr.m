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

function [ ObservationCorr ] = CalcObservationCorr( CorrMatXY, idf, lastCorr )
%CALCOBSERVATIONCORR Calculate the arithmetic mean of the correlation
%between the observed landmarks


ObservationCorr=0;
n=size(idf,2);

if n>=2
    for row=1:n-1
        for col=row+1:n
            ObservationCorr=ObservationCorr+CorrMatXY(idf(row),idf(col));
        end
    end

    %Arithmetic mean
    i=(n^2-n)/2;
    ObservationCorr=ObservationCorr/i;
else
    ObservationCorr=lastCorr;
end
    
end

