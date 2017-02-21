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
% plots PA result plot offline using the variable "data" which contain the
% results of a successful run of data = ekfslam_sim(lm, wp, object, wall, oi, 0)
%load('/Users/jos/Documents/MATLAB/SLEmotion/EmotionMaps/ExpMap.mat')
%data = ekfslam_sim(lm, wp, object, wall, oi, 0)

close all

p = data.SLEmotion.PA.p;
a = data.SLEmotion.PA.a;

numSamples = length(a);

h.fig1 = figure;
plot(1:numSamples, a)
hold on
plot(1:numSamples, p)
legend('Arousal', 'Pleasure')

hold off

% Calculate means for Rooms

disp(['Means of pleasure and arousal in R1-R6'])

R1p = mean(p(24:133));
R1a = mean(a(24:133));
disp(['R1: P = ', num2str(R1p), ...
    ' A = ', num2str(R1a)])

% R2p = mean(p(205:289));
% R2a = mean(a(205:289));
R2p = mean(p(235:289));
R2a = mean(a(235:289));
disp(['R2: P = ', num2str(R2p), ...
    ' A = ', num2str(R2a)])

% R3p = mean(p(336:510));
% R3a = mean(a(226:510));
R3p = mean(p(433:516));
R3a = mean(a(433:516));
disp(['R3: P = ', num2str(R3p), ...
    ' A = ', num2str(R3a)])

R4p = mean(p(518:603));
R4a = mean(a(518:603));
disp(['R4: P = ', num2str(R4p), ...
    ' A = ', num2str(R4a)])

R5p = mean(p(785:828)) + mean(p(932:983));
R5a = mean(a(785:828)) + mean(a(932:983));
disp(['R5: P = ', num2str(R5p), ...
    ' A = ', num2str(R5a)])

R6p = mean(p(829:931));
R6a = mean(a(829:931));
disp(['R6: P = ', num2str(R6p), ...
    ' A = ', num2str(R6a)])

disp(['R2+R3+R6: P = ', num2str(mean([R2p, R3p])), ...
    ' A = ', num2str(mean([R2a, R3a]))])