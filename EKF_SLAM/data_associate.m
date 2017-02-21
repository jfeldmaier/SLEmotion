% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%
function [zf,idf, zn, associationDist]= data_associate(x,P,z,R, gate1, gate2)
% 
% Simple gated nearest-neighbour data-association. No clever feature
% caching tricks to speed up association, so computation is O(N), where
% N is the number of features in the state.
%
% Tim Bailey 2004.

zf= []; zn= [];
idf= []; 
%gives the distance to the best match
associationDist=[];

Nxv= 3; % number of vehicle pose states
Nf= (length(x) - Nxv)/2; % number of features already in map

% linear search for nearest-neighbour, no clever tricks (like a quick
% bounding-box threshold to remove distant features; or, better yet,
% a balanced k-d tree lookup). TODO: implement clever tricks.
for i=1:size(z,2)
    jbest= 0;
    nbest= inf;
    outer= inf;
    nisbest=inf;
    
    % search for neighbours
    for j=1:Nf
        [nis, nd]= compute_association(x,P,z(1:2,i),R, j);
        if nis < gate1 & nd < nbest % if within gate, store nearest-neighbour
            nbest= nd;
            jbest= j;
            nisbest= nis;
        elseif nis < outer % else store best nis value
            outer= nis;
        end
    end
    
    % add nearest-neighbour to association list
    if jbest ~= 0
        zf=  [zf  z(:,i)];
        idf= [idf jbest];
        associationDist=[associationDist calcAssociationDist(x,z(:,i),jbest)];
    elseif outer > gate2 % z too far to associate, but far enough to be a new feature
        zn= [zn z(:,i)];
    end
end

function [nis, nd]= compute_association(x,P,z,R,idf)
%
% return normalised innovation squared (ie, Mahalanobis distance) and normalised distance
[zp,H]= observe_model(x, idf);
v= z-zp; 
v(2)= pi_to_pi(v(2));

%S= H*P*H' + R; % TODO: optimise this line -- H is sparse
S= computeS(P,H,R,idf);

nis= v'*inv(S)*v;
nd= nis + log(det(S));

function S= computeS(P,H,R,idf)
% faster computation of S -- H is sparse
jj= 2 + idf*2;
ii= [1:3 jj:(jj+1)];
H= H(:,ii); 
Pt= P(ii,ii);
S= H*Pt*H' + R;

function dist=calcAssociationDist(x, zTrue, idf)

[zExpected, ~]=observe_model(x,idf);

y1=sin(zTrue(2))*zTrue(1);
x1=cos(zTrue(2))*zTrue(1);

y2=sin(zExpected(2))*zExpected(1);
x2=cos(zExpected(2))*zExpected(1);
dist=sqrt((x2-x1)^2+(y2-y1)^2);

