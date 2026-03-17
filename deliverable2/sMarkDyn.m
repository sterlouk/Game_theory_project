function s = sMarkDyn(s0, p, M, T, N, P, Tm)
% SMARKDYN  Simulate one stochastic trajectory of the ISC Markov chain.
%
%   Strategies:
%     col 1 = sigma_All-M/2  (cooperator)
%     col 2 = sigma_All-1    (defector)
%     col 3 = sigma_G = Grim
%
% Inputs:
%   s0 : initial state [s1,s2,s3], sum=N
%   p,M,T,N : ISC / population parameters
%   P  : transition matrix from PStateTransitionGraph
%   Tm : number of steps
%
% Output:
%   s  : (Tm+1 x 3) visited states; plot(s) gives three time series

    s0 = s0(:)';
    [states, lut] = listStates(N);
    curr = lut(s0(1)+1, s0(2)+1);
    Pcum = cumsum(P, 2);

    s      = zeros(Tm+1, 3);
    s(1,:) = s0;
    for step = 1:Tm
        curr         = find(Pcum(curr,:) >= rand(), 1, 'first');
        s(step+1,:)  = states(curr,:);
    end
end

% ------------------------------------------------------------------
function [states, lut] = listStates(N)
    states = zeros((N+1)*(N+2)/2, 3);
    lut    = zeros(N+1, N+1);
    row = 0;
    for s1=0:N
        for s2=0:N-s1
            row = row+1;
            states(row,:)   = [s1, s2, N-s1-s2];
            lut(s1+1,s2+1)  = row;
        end
    end
end
