% Script to generate Markov-dynamics figures for deliverable 4

rng(42);
figDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end

% Base parameters
M = 4;
T = 10;
N = 10;
nSteps = 100;

strategy_names = {'All-M', 'All-1', 'Grim', 'GrimP', 'GrimF'};

% --- State graphs and time series ---
p_values = [0.75, 0.60];
for i = 1:length(p_values)
    p = p_values(i);
    C = computeC(M, T, p);

    % State transition diagram (projected to s2 vs sM)
    fig = plotStateGraph(C, N, sprintf('Markov state graph (p=%.2f, M=%d, T=%d, N=%d)', p, M, T, N));
    saveas(fig, fullfile(figDir, sprintf('mark_stategraph_p%03d.png', round(100*p))));

    % Time series from balanced initial state
    s0 = [2 2 2 2 2];
    [~, state_history] = markovSim5(C, N, s0, nSteps);
    fig_ts = figure('Name', sprintf('Markov Time Series (p=%.2f)', p));
    plot(0:nSteps, state_history, 'LineWidth', 1.2);
    legend(strategy_names, 'Location', 'best');
    xlabel('time step'); ylabel('count');
    title(sprintf('Markov dynamics time series (p=%.2f, M=%d, T=%d, N=%d)', p, M, T, N));
    saveas(fig_ts, fullfile(figDir, sprintf('mark_timeseries_p%03d.png', round(100*p))));
end

% --- Overlay: vary p (M=4, T=10, N=10) ---
pvals = [3/5, 2/3, 3/4, 9/10];
Xlist = cell(length(pvals), 1);
for i = 1:length(pvals)
    C = computeC(M, T, pvals(i));
    s0 = [2 2 2 2 2];
    [~, state_history] = markovSim5(C, N, s0, nSteps);
    Xlist{i} = state_history;
end
fig = overlayFigure(Xlist, pvals, strategy_names, 'MarkDyn: vary p (M=4, T=10, N=10)');
saveas(fig, fullfile(figDir, 'mark_overlay_vary_p.png'));

% --- Overlay: vary N (p=3/4, M=4, T=10) ---
Nvals = [5, 10, 15, 20];
Xlist = cell(length(Nvals), 1);
for i = 1:length(Nvals)
    C = computeC(M, T, 3/4);
    s0 = repmat(Nvals(i)/5, 1, 5);
    [~, state_history] = markovSim5(C, Nvals(i), s0, nSteps);
    Xlist{i} = state_history;
end
fig = overlayFigure(Xlist, Nvals, strategy_names, 'MarkDyn: vary N (p=3/4, M=4, T=10)');
saveas(fig, fullfile(figDir, 'mark_overlay_vary_N.png'));

% --- Overlay: vary T (p=3/4, M=4, N=10) ---
Tvals = [2, 5, 10, 20];
Xlist = cell(length(Tvals), 1);
for i = 1:length(Tvals)
    C = computeC(M, Tvals(i), 3/4);
    s0 = [2 2 2 2 2];
    [~, state_history] = markovSim5(C, N, s0, nSteps);
    Xlist{i} = state_history;
end
fig = overlayFigure(Xlist, Tvals, strategy_names, 'MarkDyn: vary T (p=3/4, M=4, N=10)');
saveas(fig, fullfile(figDir, 'mark_overlay_vary_T.png'));

% --- Overlay: vary M (p=3/4, T=10, N=10) ---
Mvals = [2, 4, 6, 8];
Xlist = cell(length(Mvals), 1);
for i = 1:length(Mvals)
    C = computeC(Mvals(i), T, 3/4);
    s0 = [2 2 2 2 2];
    [~, state_history] = markovSim5(C, N, s0, nSteps);
    Xlist{i} = state_history;
end
fig = overlayFigure(Xlist, Mvals, strategy_names, 'MarkDyn: vary M (p=3/4, T=10, N=10)');
saveas(fig, fullfile(figDir, 'mark_overlay_vary_M.png'));

disp('Markov figures generated.');

% -------------------------------------------------------------------------
function fig = plotStateGraph(C, N, titleStr)
    [P, states] = buildMarkovP5(C, N);

    s2 = states(:,2);
    sM = states(:,1) + states(:,3) + states(:,4) + states(:,5);

    fig = figure('Name', titleStr); hold on;

    % Draw transitions
    [iIdx, jIdx, vVal] = find(P);
    for k = 1:length(vVal)
        if iIdx(k) == jIdx(k), continue; end
        if vVal(k) < 1e-8, continue; end
        x0 = s2(iIdx(k)); y0 = sM(iIdx(k));
        x1 = s2(jIdx(k)); y1 = sM(jIdx(k));
        quiver(x0, y0, 0.8*(x1-x0), 0.8*(y1-y0), 0, 'k', 'MaxHeadSize', 0.4, 'LineWidth', 0.4);
    end

    % Mark absorbing vs transient states
    absorbing = abs(diag(P) - 1) < 1e-12;
    plot(s2(~absorbing), sM(~absorbing), 'r.', 'MarkerSize', 10);
    plot(s2(absorbing),  sM(absorbing),  'b.', 'MarkerSize', 12);

    xlabel('s_2  (All-1 count)');
    ylabel('s_M  (All-M + Grim + GrimP + GrimF)');
    title(titleStr);
    xlim([-0.5 N+0.5]); ylim([-0.5 N+0.5]);
    axis equal; box on; hold off;
end

function fig = overlayFigure(Xlist, vals, stratNames, titleStr)
    fig = figure('Units', 'pixels', 'Position', [100 100 1200 600]);
    nStrat = numel(stratNames);
    nRows = 2; nCols = 3;
    for k = 1:nStrat
        subplot(nRows, nCols, k); hold on;
        labels = cell(length(vals), 1);
        for i = 1:length(vals)
            y = Xlist{i}(:,k);
            plot(0:(length(y)-1), y, 'LineWidth', 1.1);
            if isnumeric(vals(i))
                labels{i} = sprintf('%.4g', vals(i));
            else
                labels{i} = char(vals(i));
            end
        end
        title(stratNames{k});
        xlabel('time step'); ylabel('count');
        legend(labels, 'Location', 'best', 'FontSize', 7);
        hold off;
    end
    sgtitle(titleStr);
    if nRows * nCols > nStrat
        subplot(nRows, nCols, nRows*nCols); axis off;
    end
end
