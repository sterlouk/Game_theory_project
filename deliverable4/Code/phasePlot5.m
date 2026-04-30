function phasePlot5(C, x0_mat, tspan, titleStr, figHandle)
% PHASEPLOT5  Phase portrait of 5-strategy replicator dynamics on a pentagon.
%
%   phasePlot5(C, x0_mat, tspan, titleStr)
%   phasePlot5(C, x0_mat, tspan, titleStr, figHandle)
%
%   For each initial condition in x0_mat the ODE is integrated and the
%   resulting trajectory is projected onto the 2-D pentagon using pentaBary.
%   The starting point is marked with a circle, the endpoint with a square.
%
%   Arguments:
%     C          - 5x5 payoff matrix
%     x0_mat     - (K x 5) matrix of initial frequency vectors
%                  (rows auto-normalised to the simplex)
%     tspan      - [t0  tf] integration window  (default [0 60])
%     titleStr   - figure title string          (default 'Phase Portrait')
%     figHandle  - existing figure handle (optional; creates new if absent)

if nargin < 3 || isempty(tspan),    tspan    = [0 60];         end
if nargin < 4 || isempty(titleStr), titleStr = 'Phase Portrait (RD)'; end
if nargin < 5
    figHandle = figure('Units','centimeters','Position',[2 2 14 14]);
end
figure(figHandle); clf;

% Add the directory of this file to the path to ensure helper functions are found
addpath(fileparts(mfilename('fullpath')));

drawPentagon();
title(titleStr, 'FontSize', 12, 'Interpreter', 'latex');

K    = size(x0_mat, 1);
cmap = lines(K);

ode_fn = @(t,x) repDyn5(t, x, C);
opts   = odeset('RelTol',1e-8,'AbsTol',1e-10,'Events',@simplex_stop);

for i = 1:K
    x0 = x0_mat(i,:)';
    x0 = max(x0, 0);
    x0 = x0 / sum(x0);

    [~, Xtraj] = ode45(ode_fn, tspan, x0, opts);

    [px, py] = pentaBary(Xtraj);

    % Trajectory line
    plot(px, py, '-', 'Color', cmap(i,:), 'LineWidth', 1.3);

    % Start marker (circle)
    [px0, py0] = pentaBary(x0');
    plot(px0, py0, 'o', 'Color', cmap(i,:), ...
         'MarkerFaceColor', cmap(i,:), 'MarkerSize', 5);

    % End marker (filled square)
    plot(px(end), py(end), 's', 'Color', cmap(i,:), ...
         'MarkerFaceColor', cmap(i,:), 'MarkerSize', 7);
end

% Mark the five pure-strategy vertices
V = eye(5);
[vx, vy] = pentaBary(V);
plot(vx, vy, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 9, 'LineWidth', 1.2);
end

% -----------------------------------------------------------------------
function [val, ist, dir] = simplex_stop(~, x)
% Stop integration if any component drops below -0.02 (left simplex)
val = min(x) + 0.02;
ist = 1;
dir = -1;
end