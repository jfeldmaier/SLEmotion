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

classdef parameterSetupClass < handle
    %PARAMETERSETUP To Setup all parameters for SLEmotion
    
    properties
        PADfactor;
        famFactorLm=[0.1 0.05];
        intPleasConst=struct('newlandmark', 0.3, 'knownlandmark', 0.3);
        sudConst=struct('knownlandmark', 0, 'newlandmark', 1);
        predConst=struct('knownlandmark', 0.5, 'newlandmark', -1, 'securitySit', 0.5);
        relConst=struct('securitySit', 1);
        %where density reaches Maximum=1
        maxLMDensity=3;
        securitySit=struct('maxCov', 2, 'dqCov', 0.1, 'nqCorr', 5, 'riseFactor', 0.2, 'decayFactor', 0.05);
        %reject gate for association
        gateReject;
        %Maximum range of sight
        maxRange
        %Maximum ratio meanPointError of Vehicle to size of Path
        Cov2AreaRange
        %time between predicts
        dtControl
        %time between Observations
        dtObserve
        %Parameters for CorrMap and PathMap
        Maps
        %medium Stepsize and maxStepsize
        stepSize;
        maxStepDiff;
        %Factor for exponential decay in density
        lmDensityFactor
        %Factor for exponential rise in tLastLmSighting
        lastLmTimeFactor
        %Factor for decay in tFirstSighting in Turn
        observationTimeFactor
        %appraisal ration setups
        appraisalRatioLandmark
        appraisalRatioSituation
        StimuliRatio
        %plot setup for PA-timeline
        tTimeline
        %plot Setups
        plotSetup
        saveMovie
    end
    
    methods
        function obj=parameterSetupClass(varargin)
            optionNames={'famFactorLm'; 'PADdecay'; 'PADcenter'; 'PADfactor'; 'intPleasConst'; 'sudConst'; 'predConst'; 'maxLMDensity'; 'securitySit';...
                'dtCalcCorr'; 'dXCorrCov'; 'relConst'; 'gateReject'; 'maxRange'; 'dtControl'; 'dtObserve'; 'Maps'; 'stepSize'; 'maxStepDiff'; ...
                'lmDensityFactor'; 'lastLmTimeFactor'; 'observationTimeFactor'; 'appraisalRatioLandmark'; 'appraisalRatioSituation'; ...
                'StimuliRatio'; 'tTimeline'; 'plotSetup'; 'saveMovie'; 'Cov2AreaRange'};
            
            for pair = reshape(varargin,2,[]) 
                inpName=cell2mat(pair(1));
                if any(strcmpi(inpName,optionNames))
                    obj.(inpName) = pair{2};
                else
                    error('%s is not a recognized parameter name',inpName)
                end
            end
            
        end
    end
    
end

