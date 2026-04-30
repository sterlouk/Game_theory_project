function phasePlot5_fixed(C, x0_mat, tspan, titleStr, figHandle)
% PHASEPLOT5_FIXED  Phase portrait of 5-strategy replicator dynamics (fixed).
% This version removes the premature event stopping condition.

if nargin < 3 || isempty(tspan),    tspan    = [0 60];         end
if nargin < 4 || isempty(titleStr), titleStr = 'Phase Portrait (RD)'; end
if nargin < 5
    figHandle = figure('Units','centimeters','Position',[2 2 14 14]);
end
figure(figHandle); clf;

addpath(fileparts(mfilename('fullpath')));

drawPentagon();
title(titleStr, 'FontSize', 12, 'Interpreter', 'latex');

K    = size(x0_mat, 1);
cmap = lines(K);

% The 'Events' option has been removed to allow full trajectories
ode_fn = @(t,x) repDyn5(t, x, C);
opts   = odeset('RelTol',1e-8,'AbsTol',1e-10);

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
