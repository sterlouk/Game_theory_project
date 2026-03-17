function x = xRepDyn(x0, p, M, T, Tf)
% XREPDYN  Simulate the ISC replicator dynamics.
%
%   dx_m/dt = x_m * ( (C*x)_m - x'*C*x )
%
%   Strategies (matching paper convention):
%     1 = sigma_All-M/2  (cooperator)
%     2 = sigma_All-1    (defector)
%     3 = sigma_G = Grim
%
% Inputs:
%   x0 : initial frequencies (3-vector, normalised internally)
%   p  : terminator payoff share, p in (0.5, 1]
%   M  : number of centipede stages (must be even)
%   T  : number of ISC rounds
%   Tf : final simulation time
%
% Output:
%   x  : (3 x npts) frequency matrix; use plot(x') for time series

    C  = buildC(p, M, T);
    x0 = x0(:) / sum(x0);
    opts   = odeset('RelTol',1e-9,'AbsTol',1e-11,'NonNegative',[1 2 3]);
    [~, x] = ode45(@(t,xv) rhs(xv,C), [0 Tf], x0, opts);
    x = x';
end

% ------------------------------------------------------------------
function dxdt = rhs(x, C)
    x    = max(x,0);  x = x/(sum(x)+eps);
    Cx   = C*x;
    dxdt = x .* (Cx - x'*Cx);
end

% ------------------------------------------------------------------
function C = buildC(p, M, T)
    k   = M/2;
    Akk = k;  Ak1 = 3*(1-p);  A1k = 3*p;  A11 = 1;
    AMM = M;  AkM = (2*k+1)*p;  AMk = (2*k+1)*(1-p);
    C = [ T*Akk,              T*Ak1,             AkM+(T-1)*Ak1 ;
          T*A1k,              T*A11,             A1k+(T-1)*A11 ;
          AMk+(T-1)*A1k,  Ak1+(T-1)*A11,             T*AMM ];
end
