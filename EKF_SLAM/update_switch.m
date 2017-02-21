% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%

function update_switch(z,R,idf,batch)
% function update(z,R,idf, batch)
%
% Inputs:
%   z, R - range-bearing measurements and covariances
%   idf - feature index for each z
%   batch - switch to specify whether to process measurements together or sequentially
%
% Outputs:
%   XX, PX - updated state and covariance (global variables)

if batch == 1
    batch_update(z,R,idf);
else
    single_update(z,R,idf);
end