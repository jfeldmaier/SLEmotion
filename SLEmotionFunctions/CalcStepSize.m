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

function [ step ] = CalcStepSize( path, parameterSetup, meanStep )
%CALCSTEPSIZE Calculates the distance between the last nr points of the path and
%returns the maximum differenz to the medium Stepsize after the last
%Observation turn

%Achtung: 
%Observation wird nur alle x*dtControl gemacht (standard x=8). Also
%verläuft der path über x+1 punkte relativ konstant und macht erst dann,
%wenn erforderlich einen Sprung.


%path ist mit Nullen aufgefüllt
path=[[0;0;0], path(1:3,path(1,:)~=0)];


%differenz to medium StepSize
nr=parameterSetup.dtObserve/parameterSetup.dtControl;

if size(path,2)>=2*nr
    stepVec=((path(:,end-nr:end)-path(:,end-nr-1:end-1)).^2);
    step=min( parameterSetup.maxStepDiff, max( abs( (sqrt(stepVec(1,:)+stepVec(2,:) )./meanStep)-1) ) );
else
    step=parameterSetup.maxStepDiff;
end


    
end

