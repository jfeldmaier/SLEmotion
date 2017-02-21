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
% Daten aus Studie
A_m = [-0.2667 0.2500 -0.5000];
A_std = [0.46855 0.53739 0.34740];

P_m = [0.283 -0.5167 0.1333 ];
P_std = [0.46763 0.40436 0.45359];

fSize = 14;

close all

subplot(211)
errorbar([1 2 3],A_m,A_std, 'LineWidth', 2, 'Color', 'b')
ylabel('arousal', 'FontSize', fSize)
set(gca,'XTickLabel',{' ', 'S1',' ','S2',' ','S3',' '}, 'FontSize', fSize)
subplot(212)
errorbar([1 2 3],P_m,P_std, 'LineWidth', 2, 'Color', 'r')
ylabel('pleasure', 'FontSize', fSize)
%xticks([1 2 3])
%xticklabels({'S1','S2','S3'})
set(gca,'XTickLabel',{' ', ' ',' ',' ',' ',' ',' '}, 'FontSize', fSize)

set(gcf, 'PaperPosition', [-0.0 -0.0 7.0 3.1]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [7 3]); %Set the paper to have width 5 and height 5.
saveas(gcf, ['arousal_pleasure_survey', datestr(now, 'HHmmss')], 'pdf')