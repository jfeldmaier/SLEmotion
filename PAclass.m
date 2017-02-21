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

classdef PAclass < handle
%PAD Summary 
% Klasse für den GE-Raum oder PA-Space
    
    properties
        %achsen des PAD-Raums
        p=0;
        a=0;
        PAcenter=[0,0];
        
        parameterSetup;
        
    end
    
    methods
        function obj=PAclass(parameterSetup)
            obj.parameterSetup=parameterSetup;
        end
        
        function update(obj, p, a)
            %berechnung des neuen Referenzpunktes
            obj.p=[obj.p obj.p(end)-(obj.p(end)-p)*obj.parameterSetup.PADfactor.p];
            obj.a=[obj.a obj.a(end)-(obj.a(end)-a)*obj.parameterSetup.PADfactor.a];
        end
        
        function [p,a]=getPA(obj, last)
            if last
                p=obj.p(end);
                a=obj.a(end);
            else
                p=obj.p;
                a=obj.a;          
            end
        end
        
    end
    
end

