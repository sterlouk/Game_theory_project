function [t, X, Y] = xRepDyn2pop(C, x0, y0, tspan)
% XREPDYN2POP  Integrate the two-population ISC replicator dynamics.
%
%   [t, X, Y] = xRepDyn2pop(C, x0, y0, tspan)
%
%   Arguments:
%     C      - 3x3 payoff matrix
%     x0     - 3x1 initial frequencies for Population 1
%     y0     - 3x1 initial frequencies for Population 2
%     tspan  - [t0 tf] or vector of time points  (default [0 80])
%
%   Returns:
%     t  - (nT x 1) time vector
%     X  - (nT x 3) pop-1 frequencies over time
%     Y  - (nT x 3) pop-2 frequencies over time

if nargin < 4, tspan = [0 80]; end

x0 = max(x0(:),0);  x0 = x0/sum(x0);
y0 = max(y0(:),0);  y0 = y0/sum(y0);
z0 = [x0; y0];

ode_fn = @(t,z) repDyn2pop(t, z, C);
opts   = odeset('RelTol',1e-9,'AbsTol',1e-11,...
                'Events',@simplexEvent);

[t, Z] = ode45(ode_fn, tspan, z0, opts);

X = Z(:,1:3);
Y = Z(:,4:6);

% re-project columns onto simplex
X = bsxfun(@rdivide, max(X,0), sum(max(X,0),2));
Y = bsxfun(@rdivide, max(Y,0), sum(max(Y,0),2));
end

% -----------------------------------------------------------------------
function [val, ist, dir] = simplexEvent(~, z)
val = min(z) + 1e-4;
ist = 1;
dir = -1;
end
