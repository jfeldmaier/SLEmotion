% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%
function [z,idf]= get_observations(x, lm, idf, rmax, walls, SWITCH_WALLS)
%function [z,idf]= get_observations(x, lm, idf, rmax)
%
% INPUTS:
%   x - vehicle pose [x;y;phi]
%   lm - set of all landmarks
%   idf - index tags for each landmark
%   rmax - maximum range of range-bearing sensor 
%
% OUTPUTS:
%   z - set of range-bearing observations
%   idf - landmark index tag for each observation
%
% Tim Bailey 2004.

[lm,idf]= get_visible_landmarks(x,lm,idf,rmax, walls, SWITCH_WALLS);
z= compute_range_bearing(x,lm);

%
%

function [lm,idf]= get_visible_landmarks(x,lm,idf,rmax, walls, SWITCH_WALLS)
% Select set of landmarks that are visible within vehicle's semi-circular field-of-view
dx= lm(1,:) - x(1);
dy= lm(2,:) - x(2);
phi= x(3);

% incremental tests for bounding semi-circle
ii= find(abs(dx) < rmax & abs(dy) < rmax ... % bounding box
      & (dx*cos(phi) + dy*sin(phi)) > 0 ...  % bounding line
      & (dx.^2 + dy.^2) < rmax^2);           % bounding circle
% Note: the bounding box test is unnecessary but illustrates a possible speedup technique
% as it quickly eliminates distant points. Ordering the landmark set would make this operation
% O(logN) rather that O(N).


if SWITCH_WALLS==1
    %is lm behind a wall?
    iivisible=[];
    for j=ii
        temp=0;
        for i=1:size(walls,2)
            if (~isempty(polyxpoly(walls(i).x(1,:), walls(i).x(2,:), [x(1) lm(1,j)], [x(2) lm(2,j)])))
                temp=1;
                break;
            end
        end   
        if temp==0
            iivisible=[iivisible j]; 
        end
    end
else
    iivisible=ii;
end

lm= lm(:,iivisible);
idf= idf(iivisible);




function z= compute_range_bearing(x,lm)
% Compute exact observation
dx= lm(1,:) - x(1);
dy= lm(2,:) - x(2);
phi= x(3);
z= [sqrt(dx.^2 + dy.^2);
    atan2(dy,dx) - phi;
    lm(3,:)];
    