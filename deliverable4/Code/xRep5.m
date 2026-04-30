% Script to generate replicator-dynamics figures for deliverable 4

rng(42);
figDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end

% Base parameters
M = 4;
T = 10;
Tf = 100;
tspan = [0 Tf];

% Shorter window for overlays to make early transients visible
tspan_overlay = [0 10];

% Fixed overlay initial condition (avoid rest points)
x0_overlay = [0.05; 0.80; 0.05; 0.05; 0.05];
x0_overlay = x0_overlay / sum(x0_overlay);

% Initial conditions for phase portraits
x0_mat = [
    1/5 1/5 1/5 1/5 1/5;       % Barycenter
    0.96 0.01 0.01 0.01 0.01;  % Near All-M
    0.01 0.96 0.01 0.01 0.01;  % Near All-1
    0.01 0.01 0.96 0.01 0.01;  % Near Grim
    0.01 0.01 0.01 0.96 0.01;  % Near Grim-Patient
    0.01 0.01 0.01 0.01 0.96;  % Near Grim-Forgiver
    0.49 0.01 0.49 0.005 0.005;% High All-M and Grim
    0.10 0.80 0.025 0.025 0.05 % High All-1
];

strategy_names = {'All-M', 'All-1', 'Grim', 'GrimP', 'GrimF'};

% --- Phase portraits and time series ---
p_values = [0.75, 0.60];
for i = 1:length(p_values)
    p = p_values(i);
    C = computeC(M, T, p);

    % Phase portrait
    fig_title = sprintf('Replicator Dynamics (M=%d, T=%d, p=%.2f)', M, T, p);
    fig_handle = figure('Name', fig_title);
    phasePlot5_fixed(C, x0_mat, tspan, fig_title, fig_handle);
    saveas(fig_handle, fullfile(figDir, sprintf('rep_phase_p%03d.png', round(100*p))));

    % Time series (use non-rest initial condition for visible dynamics)
    x0 = [0.05; 0.80; 0.05; 0.05; 0.05];
    x0 = x0 / sum(x0);
    [t, X] = runReplicator(C, x0, tspan);
    fig_ts = figure('Name', sprintf('Replicator Time Series (p=%.2f)', p));
    plot(t, X, 'LineWidth', 1.5);
    legend(strategy_names, 'Location', 'best');
    xlabel('time'); ylabel('frequency');
    title(sprintf('Replicator dynamics time series (p=%.2f, M=%d, T=%d)', p, M, T));
    saveas(fig_ts, fullfile(figDir, sprintf('rep_timeseries_p%03d.png', round(100*p))));
end

% --- Overlay: vary p (M=4, T=10) ---
pvals = [3/5, 2/3, 3/4, 9/10];
Xlist = cell(length(pvals), 1);
tlist = cell(length(pvals), 1);
for i = 1:length(pvals)
    C = computeC(M, T, pvals(i));
    [tlist{i}, Xlist{i}] = runReplicator(C, x0_overlay, tspan_overlay);
end
fig = overlayFigure(tlist, Xlist, pvals, strategy_names, 'RepDyn: vary p (M=4, T=10)');
saveas(fig, fullfile(figDir, 'rep_overlay_vary_p.png'));

% --- Overlay: vary M (p=3/4, T=10) ---
Mvals = [2, 4, 6, 8];
Xlist = cell(length(Mvals), 1);
tlist = cell(length(Mvals), 1);
for i = 1:length(Mvals)
    C = computeC(Mvals(i), T, 3/4);
    [tlist{i}, Xlist{i}] = runReplicator(C, x0_overlay, tspan_overlay);
end
fig = overlayFigure(tlist, Xlist, Mvals, strategy_names, 'RepDyn: vary M (p=3/4, T=10)');
saveas(fig, fullfile(figDir, 'rep_overlay_vary_M.png'));

% --- Overlay: vary T (p=3/4, M=4) ---
Tvals = [2, 5, 10, 20];
Xlist = cell(length(Tvals), 1);
tlist = cell(length(Tvals), 1);
for i = 1:length(Tvals)
    C = computeC(M, Tvals(i), 3/4);
    [tlist{i}, Xlist{i}] = runReplicator(C, x0_overlay, tspan_overlay);
end
fig = overlayFigure(tlist, Xlist, Tvals, strategy_names, 'RepDyn: vary T (p=3/4, M=4)');
saveas(fig, fullfile(figDir, 'rep_overlay_vary_T.png'));

disp('Replicator figures generated.');

% -------------------------------------------------------------------------
function [t, X] = runReplicator(C, x0, tspan)
    ode_fn = @(t,x) repDyn5(t, x, C);
    opts = odeset('RelTol',1e-8,'AbsTol',1e-10);
    [t, X] = ode45(ode_fn, tspan, x0, opts);
end

function fig = overlayFigure(tlist, Xlist, vals, stratNames, titleStr)
    fig = figure('Units', 'pixels', 'Position', [100 100 1200 600]);
    nStrat = numel(stratNames);
    nRows = 2; nCols = 3;
    for k = 1:nStrat
        subplot(nRows, nCols, k); hold on;
        labels = cell(length(vals), 1);
        for i = 1:length(vals)
            plot(tlist{i}, Xlist{i}(:,k), 'LineWidth', 1.4);
            if isnumeric(vals(i))
                labels{i} = sprintf('%.4g', vals(i));
            else
                labels{i} = char(vals(i));
            end
        end
        title(stratNames{k});
        xlabel('time'); ylabel('frequency');
        legend(labels, 'Location', 'best', 'FontSize', 7);
        hold off;
    end
    sgtitle(titleStr);
    if nRows * nCols > nStrat
        subplot(nRows, nCols, nRows*nCols); axis off;
    end
end
