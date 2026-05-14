function dz = repDyn2pop(~, z, C, beta)
% REPDYN2POP  Two-population replicator dynamics ODE right-hand side.
%
%   dz = repDyn2pop(t, z, C, beta)
%
%   Implements equations (B.1)-(B.2) from Lazaridis & Kehagias (2026):
%
%     dx_m/dt = x_m * ( (C*y)_m  -  x'*C*y )          ... (B.1)
%     dy_m/dt = y_m * ( (x'*C)_m  -  x'*C*y )          ... (B.2)
%
%   where x = Population 1 frequencies, y = Population 2 frequencies.
%   Both populations use the SAME strategy set and payoff matrix C.
%   NOTE: (x'*C)_m = (C'*x)_m = m-th element of column-player fitness.
%         The mean fitness x'*C*y is SHARED by both equations.
%
%   State vector:  z = [x1; x2; x3; y1; y2; y3]  (6 x 1)
%
%   Arguments:
%     z  - 6x1 state: first 3 entries = pop-1 frequencies,
%                      last  3 entries = pop-2 frequencies
%     C  - 3x3 ISC payoff matrix
%     beta - selection intensity scaling (default 1)

if nargin < 4 || isempty(beta), beta = 1; end

% --- unpack & project onto simplex -----------------------------------
x = z(1:3);   y = z(4:6);
x = max(x,0); x = x/sum(x);
y = max(y,0); y = y/sum(y);

% --- mean fitness (scalar, shared by both populations) ---------------
xCy  = x' * C * y;          % scalar

% --- (B.1): pop-1 ---------------------------------------------------
Cy   = C * y;                % 3x1: fitness of each pop-1 strategy vs pop-2
dxdt = beta * x .* (Cy  - xCy);

% --- (B.2): pop-2 ---------------------------------------------------
%   (x'*C)_m = m-th component => this is (C'*x)
CtX  = C' * x;               % 3x1: fitness of each pop-2 strategy vs pop-1
dydt = beta * y .* (CtX - xCy);

dz = [dxdt; dydt];
end
