% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%
function batch_update(z,R,idf)
global XX PX

lenz= size(z,2);
lenx= length(XX);
H= zeros(2*lenz, lenx);
v= zeros(2*lenz, 1);
RR= zeros(2*lenz);

for i=1:lenz
    ii= 2*i + (-1:0);
    [zp,H(ii,:)]= observe_model(XX, idf(i));
    
    v(ii)=      [z(1,i)-zp(1);
        pi_to_pi(z(2,i)-zp(2))];
    RR(ii,ii)= R;
end
        
KF_cholesky_update(v,RR,H);