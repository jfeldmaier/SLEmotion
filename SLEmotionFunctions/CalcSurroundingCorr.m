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


function [ SurroundingCorr ] = CalcSurroundingCorr( x, CorrMatXY, n )
%CALCCURRENTCORR Calculate The Correlation between the surrounding lm


xv=repmat(x(1:2),(size(x,1)-3)/2,1);
diff=(x(4:end)-xv);
diff=diff.^2;

distance(1:(size(x,1)-3)/2)=sqrt(diff(1:2:end)+diff(2:2:end))';
[D, I]=sort(distance);

SurroundingCorr=0;

if size(D,2)>=n
    for row=1:n-1
        for col=row+1:n
            SurroundingCorr=SurroundingCorr+CorrMatXY(I(row),I(col));
        end
    end
    %Arithmetic mean
    i=(n^2-n)/2;
    SurroundingCorr=SurroundingCorr/i;
end

end

