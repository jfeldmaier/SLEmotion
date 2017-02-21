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

load bostemp

T = 10*(1/50);
Fs = 1000;
dt = 1/Fs;
t = 0:dt:T-dt;
x = zeros(1,length(t));
xMaxStore = zeros(1,length(t));
xMax = 0;
for i = 1:length(t)
% x(i) = abs((t(i).*3.5).*sawtooth(2*pi*50*t(i)));

x(i) = abs(tempC(i));

xMax = max(x(i), xMax);
xMaxStore(i) = xMax;

predSit(i) = 2*(x(i)/xMax)-1;

end



plot(t,x, 'LineWidth', 2)
hold on
plot(t,xMaxStore, 'LineWidth', 2)
plot(t,predSit, 'LineWidth', 2)
hold off