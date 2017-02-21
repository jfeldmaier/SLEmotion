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

classdef landmarkClass < handle
%LANDMARK 
% Klasse zur Bewertung von Landmarken
%
    
    properties
        id
        %array of observed Landmarkpositions [x;y;time]
        position=[];
        %Time of last sighting
        tSightings;
        %Nr of Sightings
        nrSightings=1;
        %Time of First Sighting in this Observation
        tFirstSighting;


        %array of observed covariance of the landmark
        cov=[];
        covNorm=[];
        %parameter Setup
        parameterSetup;
        %Landmark Density
        LmDensity
        
        %appraisal register   
        familiarity=-1;
        suddeness
        predictability
        conduciveness
        relevance
        intpleasentness
        
    end
    
    methods
        %Konstruktor für neue Landmarke
        function obj=landmarkClass(id, time, position, covariance, parameterSetup, LmDensity, tLastLmSighting)
            obj.id=id;
            obj.position=position;
            obj.cov=covariance;
            obj.tSightings=time;
            obj.parameterSetup=parameterSetup;
            obj.LmDensity=LmDensity;
            obj.tFirstSighting=time;
            
            %arousal register
            obj.suddeness=obj.parameterSetup.sudConst.newlandmark;
            obj.predictability=obj.parameterSetup.predConst.newlandmark;
            %obj.relevance=1-exp(-(time-obj.tSightings(max(1,end-1))));
            obj.relevance=1-exp(-tLastLmSighting/obj.parameterSetup.lastLmTimeFactor);
            
            %valence register
            obj.intpleasentness=obj.parameterSetup.intPleasConst.newlandmark;
            obj.conduciveness=1-(min(obj.LmDensity, obj.parameterSetup.maxLMDensity)/obj.parameterSetup.maxLMDensity);
            
        end
        
        %jeden Zeitschritt wird die Vertrautheit aller Landmarken
        %aktualisiert
        function updateFam(obj, observed)
            if observed
                %calculate the factor dependig on the association distance
                distFact=obj.parameterSetup.famFactorLm.rise;
                obj.familiarity=obj.familiarity+(1-obj.familiarity)*distFact;
            else
                obj.familiarity=obj.familiarity+(-1-obj.familiarity)*obj.parameterSetup.famFactorLm.decay;
            end;
        end
        
        %update function for known landmarks in the memory
        function update(obj, time, position, covariance, corr, LmDensity)
            obj.nrSightings=obj.nrSightings+1;
            obj.tSightings=[obj.tSightings time];
            obj.position=[obj.position position];
            obj.cov=[obj.cov covariance]; 
            obj.covNorm=obj.cov/max(obj.cov);
            obj.LmDensity=LmDensity;
            
            if (obj.tSightings(end)-obj.tSightings(end-1))>obj.parameterSetup.dtObserve*2
                obj.tFirstSighting=obj.tSightings(end);
            end
            
            if (obj.tSightings(end)-obj.tFirstSighting)>obj.parameterSetup.dtObserve*2
                obj.suddeness=-1;
            else
                obj.suddeness=obj.parameterSetup.sudConst.knownlandmark;
            end
                        
            obj.predictability=1-obj.covNorm(end);
            %exponentiell abhängig von der vergangenen Zeit seit der ersten
            %Sichtung im jeweiligen turn [0,1]
            obj.relevance=exp(-((time-obj.tFirstSighting)/obj.parameterSetup.observationTimeFactor));

            %valence register
            obj.intpleasentness=2*corr-1;
            %obj.intpleasentness=associationDist;
            %depending on the density of Landmarks in the position
            obj.conduciveness=1-(min(obj.LmDensity, obj.parameterSetup.maxLMDensity)/obj.parameterSetup.maxLMDensity);
        end
          
       
    end
    
end

