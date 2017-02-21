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

classdef SLEmotionEngineClass < handle
%SLEMOTIONENGINE 
%
% Die Hauptklasse von SLEmotion
%
%  
%     
%     
%     
%     
%     
%     
%     
    
    properties
        %Karte un dKovarianzmatrix
        X
        P
        time
        %[xmin, ymin; xmax, ymax]
        mapLimits=[0,0;0,0];
        %Geschwindigkeit, Steuerungswinkel
        Vn=[];
        Gn=[];
        
        path=[];
        cov=[];
        corr=[];
        observationCount=0;
        
        dtCorr=0;
        
        dCov=[];
        dCorr=[];
        
        CorrMat;
        
        tLastLmSighting=inf;
        
        associationDist=[];
        
        meanStep
        step;
        stepNorm;
        
        %Karten
        MapX
        MapY
        CorrMap
        CorrMapPath      
        PathMap
        PathMapNoTime
        CovMap
        SecurityMap
        ImMat % correlation map lines
        
        pathfam=[];
        pathSize=0;
        
        Cov2Path=[];
        
        aMem=[];
        pMem=[];
        
        
        %Memory of observed landmarkes
        landmarkMemory
        situationMemory
        
        %Landmarks observed in actual turn
        activeLandmarks
        %Situation
        activeSituations
        
        %object for familiarity of the securitySituation
        securityFam;
               
        %Parameters 
        parameterSetup;
        %appraial Setup
        stimulusSetup;
        
        %PASpace
        PA;
    end
    
    methods
        
        function obj=SLEmotionEngineClass(parameterSetup,stimulusSetup)
            % Konstruktor
            obj.parameterSetup=parameterSetup;
            obj.stimulusSetup=stimulusSetup;
            obj.PA=PAclass(parameterSetup);
        end
           
        function updateProperties(obj, time, X, P, Vn, Gn, observedLandmarks, path)
            %aktualisieren aller notwendigen Parameter zur Bewertung
            
            obj.time=time;
            obj.X=X;
            obj.P=P;
            obj.Vn=Vn;
            obj.Gn=Gn;
            obj.path=path;
            obj.observationCount=obj.observationCount+1;

            
            %vehicle covariance
            obj.cov=[obj.cov CalcMeanPointError(P(1:2,1:2))];

            
            %counter for the calculation of CorrMap
            obj.dtCorr=obj.dtCorr+1;
            
            %Size of Map
            if length(obj.X)>3
                obj.mapLimits=[min([obj.mapLimits(1,1), obj.X(1), min(obj.X(4:2:end))]), min([obj.mapLimits(1,2), obj.X(2), min(obj.X(5:2:end))]);...
                    max([obj.mapLimits(2,1), obj.X(1), max(obj.X(4:2:end))]), max([obj.mapLimits(2,2), obj.X(2), max(obj.X(5:2:end))])];
            else
                obj.mapLimits=[min([obj.mapLimits(1,1), obj.X(1)]), min([obj.mapLimits(1,2), obj.X(2)]);...
                    max([obj.mapLimits(2,1), obj.X(1)]), max([obj.mapLimits(2,2), obj.X(2)])];                
            end
         
            %Corrmat
            obj.CorrMat=CalcCorrMatrix(obj.P);
            %arithmetic mean of corrX and corrY
            CorrMatXY=(abs((obj.CorrMat(4:2:end,4:2:end))+(obj.CorrMat(5:2:end,5:2:end)))/2).^2;
            
            
            %Calculate the Ratio of Cov to Size of path
            rCov=obj.cov(end)/sqrt(obj.pathSize+eps);
            rCov=max(rCov-obj.parameterSetup.Cov2AreaRange(1), 0);
            rCov=min(1, rCov/(obj.parameterSetup.Cov2AreaRange(2)-obj.parameterSetup.Cov2AreaRange(1)));
            obj.Cov2Path=[obj.Cov2Path rCov];                           
            
                
            %calc CorrMap every dtCalcCorr (Calculation of corrmap is time-expensive)
            if obj.dtCorr>=obj.parameterSetup.Maps.dtCalcMaps || isempty(obj.corr)
                %calc corr
                [obj.MapX,obj.MapY,obj.CorrMap, obj.CorrMapPath, obj.PathMap, obj.PathMapNoTime, obj.ImMat]=CalcCorrMap(CorrMatXY, obj.X, obj.mapLimits, path, obj.parameterSetup);               

                %Size of the Path
                obj.pathSize=length(obj.PathMapNoTime(obj.PathMapNoTime>=0.5))*(obj.MapX(1,2)-obj.MapX(1,1));                
                
                %CovMap
                [~,~, obj.CovMap]=CalcCovMap(obj.path, obj.Cov2Path, obj.mapLimits, obj.parameterSetup);
            
                %SecurityMap
                obj.SecurityMap=max(-1,min(1,(obj.CorrMap.*2-ones(size(obj.CorrMap)))+obj.CovMap));                
               
                obj.dtCorr=0;               
            end    
            obj.corr=[obj.corr CalcActualPositionCorr(obj.X, obj.MapX, obj.MapY, obj.CorrMap)];
            
           
            %calculate the familyvalue for the current place
            obj.pathfam=[obj.pathfam CalcPathFamiliarity(obj.X(1:2), obj.MapX, obj.MapY, obj.PathMap)];
            
            %calc the stepsize
            obj.step=[obj.step CalcStepSize(obj.path, obj.parameterSetup, mean(Vn(end-(obj.parameterSetup.dtObserve/obj.parameterSetup.dtControl):end)...
                *obj.parameterSetup.dtControl))];
            obj.stepNorm=obj.step/(max(obj.step)+eps);

            %calculate the time since the last Landmark was observed
            obj.tLastLmSighting=inf;
            for iObj=obj.landmarkMemory
                obj.tLastLmSighting=min([obj.tLastLmSighting obj.time-iObj.tSightings(end)]);
            end            
          
            %update the familiarity of landmarks
            if any(strcmpi('landmark', obj.stimulusSetup));
                for i=1:length(observedLandmarks)
                    obj.landmarkMemory(observedLandmarks(i)).updateFam(1);
                end
                notObserved=1:length(obj.landmarkMemory);
                for i=notObserved(~ismember(notObserved, observedLandmarks))
                    obj.landmarkMemory(i).updateFam(0);  
                end
            end
        end
        
        %add Stimuli to the active lists
        function addStimulus(obj, stimulusType, varargin)
            switch stimulusType
                case 'newlandmark'
                    id=cell2mat(varargin(1));
                    landmarkPos=obj.X(id*2+2:id*2+3);
                    %calc the LmDensity
                    landmarkMap=obj.X;
                    landmarkMap(id*2+2:id*2+3)=[];
                    %without observed lm
                    LmDensity=CalcLMDensity(landmarkMap(4:end), landmarkPos, obj.parameterSetup);
                                        
                    %create a new landmark object and add it to
                    %activeLandmarks list
                    newLM=landmarkClass(id, obj.time, landmarkPos, CalcCovEllipseArea(obj.P(id*2+2:id*2+3,id*2+2:id*2+3)), obj.parameterSetup, LmDensity, obj.tLastLmSighting);
                    obj.activeLandmarks=[obj.activeLandmarks newLM];
                    obj.landmarkMemory=[obj.landmarkMemory newLM];
                    
                case 'knownlandmark'
                    id=cell2mat(varargin(1));
                    landmarkPos=obj.X(id*2+2:id*2+3);
                    %calc the LmDensity
                    landmarkMap=obj.X;
                    %without observed lm
                    landmarkMap(id*2+2:id*2+3)=[];
                    LmDensity=CalcLMDensity(landmarkMap(4:end), landmarkPos, obj.parameterSetup);

                    
                    %update known landmark and move to activeLandmarks
                    obj.landmarkMemory(id).update(obj.time, landmarkPos, CalcCovEllipseArea(obj.P(id*2+2:id*2+3,id*2+2:id*2+3)), ...
                       CalcVehicle2LmCorr(obj.CorrMat, id), LmDensity);
                    obj.activeLandmarks=[obj.activeLandmarks obj.landmarkMemory(id)];
                                        
                case 'situation'
                    %create a securitySit object
                    obj.activeSituations=situationClass(obj.cov, obj.corr, obj.Cov2Path(end),...
                        CalcPathFamiliarity(obj.X(1:2), obj.MapX, obj.MapY, obj.PathMap), obj.stepNorm,...
                        obj.time, obj.X(1:2), obj.parameterSetup);
                    
            end
        end
        
        
        %Appraisal of active Stimuli
        function appraisStimuli(obj)

            p=[];
            a=[];
            d=[];
            arousalSit=[];
            pleasureSit=[];
            arousalLm=[];
            pleasureLm=[];
            
            %appraisal of situation stimuli
            for iObj=obj.activeSituations
                
                sud=iObj.suddeness;             
                fam=iObj.familiarity;
                pred=iObj.predictability;
                rel=iObj.relevance;
                cond=iObj.conduciveness;
                int=iObj.intpleasentness;
                
                           
                %Weighting of Registers
                arousalSit=[arousalSit sum([obj.parameterSetup.appraisalRatioSituation.sud*sud,...
                                       obj.parameterSetup.appraisalRatioSituation.fam*-fam,...
                                       obj.parameterSetup.appraisalRatioSituation.pred*-pred,...
                                       obj.parameterSetup.appraisalRatioSituation.rel*rel])/...
                                   sum([obj.parameterSetup.appraisalRatioSituation.sud, ...
                                        obj.parameterSetup.appraisalRatioSituation.fam, ...
                                        obj.parameterSetup.appraisalRatioSituation.pred, ...
                                        obj.parameterSetup.appraisalRatioSituation.rel])];
                pleasureSit=[pleasureSit sum([obj.parameterSetup.appraisalRatioSituation.int*int,...
                                         obj.parameterSetup.appraisalRatioSituation.cond*cond])/ ...
                                      sum([obj.parameterSetup.appraisalRatioSituation.int, ...
                                           obj.parameterSetup.appraisalRatioSituation.cond])];
                
            end
            
            
            %appraisal of Landmark stimuli
            for iObj=obj.activeLandmarks

                %get the appraisal registers
                sud=iObj.suddeness;                
                fam=iObj.familiarity;
                pred=iObj.predictability;
                rel=iObj.relevance;
                cond=iObj.conduciveness;
                int=iObj.intpleasentness;
                
                %Weighting of Registers                
                arousalLm=[arousalSit sum([obj.parameterSetup.appraisalRatioLandmark.sud*sud,...
                                       obj.parameterSetup.appraisalRatioLandmark.fam*-fam,...
                                       obj.parameterSetup.appraisalRatioLandmark.pred*-pred,...
                                       obj.parameterSetup.appraisalRatioLandmark.rel*rel])/...
                                   sum([obj.parameterSetup.appraisalRatioLandmark.sud, ...
                                        obj.parameterSetup.appraisalRatioLandmark.fam, ...
                                        obj.parameterSetup.appraisalRatioLandmark.pred, ...
                                        obj.parameterSetup.appraisalRatioLandmark.rel])];
                pleasureLm=[pleasureSit sum([obj.parameterSetup.appraisalRatioLandmark.int*int,...
                                         obj.parameterSetup.appraisalRatioLandmark.cond*cond])/ ...
                                      sum([obj.parameterSetup.appraisalRatioLandmark.int, ...
                                           obj.parameterSetup.appraisalRatioLandmark.cond])];
            end     
            
            
            arousalLm=mean(arousalLm);
            pleasureLm=mean(pleasureLm);
            
            
            %combine arousal and pleasure and update PA-space
            if ~isempty(pleasureSit)
                if ~isnan(pleasureLm)
                    p=sum([obj.parameterSetup.StimuliRatio.pleasureSit*pleasureSit, obj.parameterSetup.StimuliRatio.pleasureLm*pleasureLm])/...
                        sum([obj.parameterSetup.StimuliRatio.pleasureSit, obj.parameterSetup.StimuliRatio.pleasureLm]);
                    a=sum([obj.parameterSetup.StimuliRatio.arousalSit*arousalSit, obj.parameterSetup.StimuliRatio.arousalLm*arousalLm])/ ...
                        sum([obj.parameterSetup.StimuliRatio.arousalSit, obj.parameterSetup.StimuliRatio.arousalLm]);                    
                else
                    p=(obj.parameterSetup.StimuliRatio.pleasureSit*pleasureSit)/...
                        sum([obj.parameterSetup.StimuliRatio.pleasureSit, obj.parameterSetup.StimuliRatio.pleasureLm]);
                    a=(obj.parameterSetup.StimuliRatio.arousalSit*arousalSit)/...
                        sum([obj.parameterSetup.StimuliRatio.arousalSit, obj.parameterSetup.StimuliRatio.arousalLm]);
                end
            else
                if ~isnan(pleasureLm)
                    p=(obj.parameterSetup.StimuliRatio.pleasureLm*pleasureLm)/...
                        sum([obj.parameterSetup.StimuliRatio.pleasureSit, obj.parameterSetup.StimuliRatio.pleasureLm]);
                    a=(obj.parameterSetup.StimuliRatio.arousalLm*arousalLm)/ ...
                        sum([obj.parameterSetup.StimuliRatio.arousalSit, obj.parameterSetup.StimuliRatio.arousalLm]);
                else
                    p=0;
                    a=0;
                end
            end
                   
          
            %update PA
            obj.PA.update(p, a);
            

            %store situation into memory and clear activeLandmarks and
            %activeSituations
            obj.activeLandmarks=[];
            obj.situationMemory=[obj.situationMemory obj.activeSituations];
            obj.activeSituations=[];
            

        end
    end
    
end

