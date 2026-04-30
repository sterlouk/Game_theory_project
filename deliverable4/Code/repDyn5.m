function dxdt = repDyn5(~, x, C)
% REPDYN5  Replicator dynamics ODE RHS for 5 strategies.
%
%   dxdt = repDyn5(t, x, C)
%
%   Implements:
%     dx_m/dt = x_m * [ (C*x)_m  -  x' * C * x ]
%
%   Arguments:
%     x  - 5x1 frequency vector (should satisfy sum=1, x>=0)
%     C  - 5x5 payoff matrix
%
%   Note: the first argument t is unused (autonomous system) but required
%   by ode45 / ode23s.

x   = max(x, 0);            % numerical floor to avoid tiny negatives
x   = x / sum(x);           % re-normalize (safety)

Cx  = C * x;                % 5x1  strategy fitnesses
avg = x' * Cx;              % scalar  mean fitness

dxdt = x .* (Cx - avg);    % 5x1  replicator equation
end