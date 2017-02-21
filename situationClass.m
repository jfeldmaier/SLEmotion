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
classdef situationClass < handle
%SECURITYSITCLASS 
%
% Klasse zur Bewertung der Situation
    
    properties        
        time
        position
        cov
        corr
        parameterSetup
        
        %appraisal register
        familiarity
        suddeness
        intpleasentness
        relevance
        predictability
        conduciveness
    end
    
    methods
        function obj=situationClass(cov, corr, rCov, fam, stepNorm, time, pos, parameterSetup)
            
            obj.parameterSetup=parameterSetup;
            obj.time=time;
            obj.position=pos;
            
            %norm covariance and cut values <0
            covNorm=1-2*(cov/(max(cov)+eps));

            
            %calc dCorr and dCov. (percental change)
            dCorr=max(min((corr(end)-(corr(max(end-1,1))))/(corr(max(end-1,1))+eps),1),-1); 
            dCov=max(min((rCov(end)-(rCov(max(end-1,1))))/(rCov(max(end-1,1))+eps),1),-1); 
            
            %calculate valence register
%             obj.intpleasentness=max(min((2*corr(end)-1)+(1-2*rCov),1),-1);
            obj.intpleasentness=max(min((corr(end)-rCov),1),-1);
            obj.conduciveness=mean([dCorr -dCov]);
            

            %calc arousal register
            obj.familiarity=fam*2-1;      
            obj.suddeness=stepNorm(end)*2-1;
            obj.predictability=covNorm(end);
            obj.relevance=obj.parameterSetup.relConst.situation;


        end
    end
    
end

