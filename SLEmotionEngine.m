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
    function SLEmotionEngine( SLEmotion, time, zf, zn, Vn, Gn, path, h, movieName)
%   SLEmotionEngine 
%   Schnittstelle von SLAM und SLEmotion. Hier werden die Stimuli
%   generiert, die Bewertung ausgelöst und die Simulation von SLEmotion
%   visualisiert
%
%
%   input:
%   zf: liste der bekannten landmarks
%   zn: liste der neuen landmarks
%   Vn: Rauschbehaftete Geschwindigkeit
%   Gn: Rauschbehafteter Steuerungswinkel
%   path: Wegpunkte
%   h: grafikhandles
%   movieName: Name des Films

% XX: Karte
% PX: Kovarianzmatrix der Karte
global XX PX

%Bei jedem aufruf werden zunächst die Parameter aktualisiert
SLEmotion.updateProperties(time, XX, PX, Vn, Gn, zf,path);

%Create newlandmark stimuli
if ~isempty(zn) && any(strcmpi('landmark', SLEmotion.stimulusSetup))
    for i=zn(1,:)
        SLEmotion.addStimulus('newlandmark', i);
    end
end    
    
%create knownlandmark stimuli
if ~isempty(zf) && any(strcmpi('landmark', SLEmotion.stimulusSetup))
    for i=1:length(zf)
        SLEmotion.addStimulus('knownlandmark', zf(i));
    end
end

%create corrsit stimulus every intervalCorrsit seconds
if any(strcmpi('situation', SLEmotion.stimulusSetup))
    SLEmotion.addStimulus('situation');
end

%bewertung der Stimuli
SLEmotion.appraisStimuli;

%% Plots

if ~isempty(h)

if mod(2, 2)<=0.1
    
    %PA plots
    if any(strcmpi(SLEmotion.parameterSetup.plotSetup, {'full', 'slender'}))
        set(h.PA, 'xdata', SLEmotion.PA.p(end), 'ydata', SLEmotion.PA.a(end));
    end
    
    if any(strcmpi(SLEmotion.parameterSetup.plotSetup, 'full'))
        %PA timeline 
        xData=(max(1,(length(SLEmotion.PA.p)-SLEmotion.parameterSetup.tTimeline/SLEmotion.parameterSetup.dtObserve)):length(SLEmotion.PA.p))*(SLEmotion.parameterSetup.dtObserve+SLEmotion.parameterSetup.dtControl);
        set(h.PAtimelineP, 'ydata', SLEmotion.PA.p(max(1,(end-SLEmotion.parameterSetup.tTimeline/SLEmotion.parameterSetup.dtObserve)):end), 'xdata', xData);
        set(h.PAtimelineA, 'ydata', SLEmotion.PA.a(max(1,(end-SLEmotion.parameterSetup.tTimeline/SLEmotion.parameterSetup.dtObserve)):end), 'xdata', xData);
        
        set(h.spPAtimeline, 'xlim', [xData(1), xData(end)+5]);
        
        %SecurityMap
        set(h.CorrMap, 'xdata', SLEmotion.MapX, 'ydata', SLEmotion.MapY, 'zdata', SLEmotion.SecurityMap);
        view(2);
        caxis([-1 1])
        axis equal
        shading interp
        %set(h.CorrMap, 'alphadata', .5);
        set(h.CorrMapPath, 'xdata', SLEmotion.path(1,:), 'ydata', SLEmotion.path(2,:), 'zdata', ones(1,size(SLEmotion.path,2)));
    end
    
    %Save Movie
    if SLEmotion.parameterSetup.saveMovie
        nrFrames=SLEmotion.observationCount;
        m=getframe(h.fig1);
        save(['Movies/' movieName '/mov' num2str(nrFrames) '.mat'], 'm');
        save(['Movies/' movieName '/nrFrames.mat'], 'nrFrames');
    end
end
end

end

