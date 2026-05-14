function [t, X, Y] = xRepDyn2pop(C, x0, y0, tspan, dynOpts)
% XREPDYN2POP  Integrate the two-population ISC replicator dynamics.
%
%   [t, X, Y] = xRepDyn2pop(C, x0, y0, tspan, dynOpts)
%
%   Arguments:
%     C      - 3x3 payoff matrix
%     x0     - 3x1 initial frequencies for Population 1
%     y0     - 3x1 initial frequencies for Population 2
%     tspan  - [t0 tf] or vector of time points  (default [0 80])
%     dynOpts - optional struct:
%               .beta     (default 1)
%               .RelTol   (default 1e-9)
%               .AbsTol   (default 1e-11)
%               .eventTol (if provided as a small positive value, stop when
%                          any component drops below -eventTol)
%
%   Returns:
%     t  - (nT x 1) time vector
%     X  - (nT x 3) pop-1 frequencies over time
%     Y  - (nT x 3) pop-2 frequencies over time

if nargin < 4 || isempty(tspan), tspan = [0 80]; end
if nargin < 5 || isempty(dynOpts), dynOpts = struct(); end

beta = 1; relTol = 1e-9; absTol = 1e-11; eventTol = [];
if isfield(dynOpts, 'beta'),     beta = dynOpts.beta; end
if isfield(dynOpts, 'RelTol'),   relTol = dynOpts.RelTol; end
if isfield(dynOpts, 'AbsTol'),   absTol = dynOpts.AbsTol; end
if isfield(dynOpts, 'eventTol'), eventTol = dynOpts.eventTol; end

x0 = max(x0(:),0);  x0 = x0/sum(x0);
y0 = max(y0(:),0);  y0 = y0/sum(y0);
z0 = [x0; y0];

ode_fn = @(t,z) repDyn2pop(t, z, C, beta);
opts   = odeset('RelTol', relTol, 'AbsTol', absTol);
if ~isempty(eventTol)
    opts = odeset(opts, 'Events', @(t,z) simplexEvent(t, z, eventTol));
end

[t, Z] = ode45(ode_fn, tspan, z0, opts);

X = Z(:,1:3);
Y = Z(:,4:6);

% re-project columns onto simplex
X = bsxfun(@rdivide, max(X,0), sum(max(X,0),2));
Y = bsxfun(@rdivide, max(Y,0), sum(max(Y,0),2));
end

% -----------------------------------------------------------------------
function [val, ist, dir] = simplexEvent(~, z, tol)
val = min(z) + tol;
ist = 1;
dir = -1;
end
