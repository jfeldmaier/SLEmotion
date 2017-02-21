% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%

function single_update(z,R,idf)
global XX PX

lenz= size(z,2);
for i=1:lenz
    [zp,H]= observe_model(XX, idf(i));
    
    v= [z(1,i)-zp(1);
        pi_to_pi(z(2,i)-zp(2))];
    
    KF_cholesky_update(v,RR,H);
end        
