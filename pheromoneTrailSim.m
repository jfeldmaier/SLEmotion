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
close all

t = 0:0.01:10;

tauTrail = 100;

trailInit = 5;

trailOut = trailInit;

t0 = 0;

for i =  1:length(t)
    trailOut = [trailOut trailOut(end) * exp((t0-t(i))/tauTrail)];
end

% trail = exp(-(t/tauTrail));

plot(t, trailOut(2:end), 'LineWidth',2)
hold on
vline(tauTrail*0.01+t0)
hold off