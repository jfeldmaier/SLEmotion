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
%SLEmotion Parameters


% 'saveMovie'           1: speichere movie, 0: normale Simulation
% 'tTimeline'           Zeithorizont im timelineplot in sec
% 'dtControl'           dt eines Zeitschritts aus config.mat
% 'dtObserve'           dt eines Observationschritts 
% 'maxRange'            Sichtweite aus config.mat        
% 'maxStepDiff'         Maximale relative Differenz zur durchschnittlichen
%                       Schrittweite seit der letzten Observierung (1=100%)
% 'PADfactor'           p Dämpfung von pleasure
%                       a Dämpfung von arousal
% 'intPleasConst'       Konstanten für int. Gefallen
% 'sudConst'            Konstante für Plötzlichkeit
% 'predConst'           Konstante für Vorhersehbarkeit
% 'relConst'            Konstante für Relevanz
% 'famFactorLm'         Faktoren für die Vertrautheit von Landmarken
% 'Maps', 
%   'pathDecayFactor'   Faktor zum Verballsen der 'Pheromonspur'
%   'nq'                Quantisierungsstufen der CorrMap
%   'scalingFactor'     Skalierung der Karten = Auflösung
%   'wrapSize'          Rand der Karte 
%   'dilateRadiusCorr'  Dilatierung der Korrelationslinien in CorrMap
%   'dilateRadiusPath'  " PathMap  
%   'dilateRadiusCov'	" CovMap
%   'switchFilterCorr'  1: Gaussfilter der CorrMap
%   'filterSizeCorr'    Größe des Gaussfilters für CorrMap    
%   'filterSizePath'	"   PathMap
%   'filterSizeCov'     "   CovMap
%   'evalDistance'      1: Bewerte die Länge der Korrelationslinien
%   'dMaxHigh'          Maximale Länge für die höchste Korrelation
%   'dMaxLow'           "   für die niedrigste Korrelation
%   'downgradeCorrFactor'   Wenn Korrelationslinie zu lang, dann
%                           runterstufen der Korrelation
%   'dtCalcMaps'        Berechnung der Karten alle dtCalcMaps
%                       Observationsschritte
% 'Cov2AreaRange'       Maximalwert des Verhältnisses zwischen Punktfehler
%                       des Vehikels und Größe der Karte
% 'maxLMDensity'        Maximalwert der Landmarkendichte
% 'lmDensityFactor'     Abfallkonstante für Lndmarkendichte
% 'lastLmTimeFactor'    Zeitkonstante für Exponentialfunktion der Relevanz bei
%                       beobachtung einer neuen Landmarke
% 'observationTimeFactor'   Zeitkonstante für Exponentialfunktion der Relevanz bei
%                           beobachtung einer bekannten Landmarke
% 'appraisalRatioLandmark'	Gewichte der Bewertung von Landmarken
% 'appraisalRatioSituation' Gewichte der Bewertung der Situation
% 'StimuliRatio'            Gewichte Stituation/Landmark
% 'plotSetup'               Ploteinstellungen der Simulation 
%                           'full': Groundtruth, SLAM Map, SecurityMap, PAspace, PAtimeline, 
%                           'slender': Groundtruth, SLAM Map, PAspace      
% 'stimulusSetup'           welche Stimuli sollen bewertet werden
%                           ('landmark' &/| 'situation')

parameterSetup=parameterSetupClass(...
    'saveMovie', 0,...
    'tTimeline', 120,...
    'dtControl', DT_CONTROLS, ...
    'dtObserve', DT_OBSERVE, ...
    'maxRange', MAX_RANGE, ... 
    'maxStepDiff', 8, ...         
    'PADfactor', struct('p', 1/10, 'a', 1/20), ... 
    'intPleasConst', struct('newlandmark', 1, 'knownlandmark', 0.3),...
    'sudConst', struct('knownlandmark', 0, 'newlandmark', 1), ...
    'predConst', struct('knownlandmark', 0.5, 'newlandmark', -1, 'situation', 0.5), ...
    'relConst', struct('situation', 0),...
    'famFactorLm', struct('rise', 0.04, 'decay', 0.01), ...
    'Maps', struct('pathDecayFactor', 100, 'nq', 20, 'scalingFactor', 2, 'wrapSize', 2, 'dilateRadiusCorr', 2, ...
        'dilateRadiusPath', 2, 'dilateRadiusCov', 1, 'switchFilterCorr', 1, 'filterSizeCorr', 2, 'filterSizePath', 1, ...
        'filterSizeCov', 1, 'dMaxHigh', MAX_RANGE*5, 'dMaxLow', MAX_RANGE, 'evalDistance', 1, ...
        'downgradeCorrFactor', 0.5, 'dtCalcMaps', 5),...
    'Cov2AreaRange', [0 0.05], ...   
    'maxLMDensity', 3, ...  
    'lmDensityFactor', 5, ...
    'lastLmTimeFactor', 10,... 
    'observationTimeFactor', 5,... 
    'appraisalRatioLandmark', struct('sud', 1, 'fam', 1, 'pred', 1, 'rel', 1, 'int', 2, 'cond', 1),... 
    'appraisalRatioSituation', struct('sud', 2, 'fam', 7, 'pred', 2, 'rel', 1, 'int', 2, 'cond', 1), ...   
    'StimuliRatio', struct('arousalSit', 7, 'arousalLm', 1, 'pleasureSit', 7, 'pleasureLm', 1), ...
    'plotSetup', {'off'});  % 'full' / 'slender' / 'off'
    

stimulusSetup={'landmark', 'situation'};

SLEmotion=SLEmotionEngineClass(parameterSetup, stimulusSetup);