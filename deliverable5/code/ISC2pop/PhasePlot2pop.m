function PhasePlot2pop(C, x0_mat, y0_mat, tspan, titleStr, dynOpts)
% PHASEPLOT2POP  Phase portrait of the two-population replicator dynamics.
%
%   PhasePlot2pop(C, x0_mat, y0_mat, tspan, titleStr, dynOpts)
%
%   Plots TWO side-by-side (x1,x2) feasible regions:
%     LEFT  = Population 1 trajectories
%     RIGHT = Population 2 trajectories
%
%   Each row of x0_mat / y0_mat is an initial condition. The two populations
%   are integrated jointly under equations (B.1)-(B.2).
%
%   Arguments:
%     C        - 3x3 ISC payoff matrix
%     x0_mat   - (K x 3) initial conditions for pop 1
%     y0_mat   - (K x 3) initial conditions for pop 2
%     tspan    - [t0 tf]            (default [0 80])
%     titleStr - base title string  (default '')

if nargin < 4 || isempty(tspan),    tspan    = [0 80]; end
if nargin < 5 || isempty(titleStr), titleStr = ''; end
if nargin < 6, dynOpts = struct(); end

K    = size(x0_mat, 1);
cmap = lines(K);

figure('Units','centimeters','Position',[2 2 26 12]);

labs = {'All-$M$','All-$1$','Grim'};
titles_ = {'Population 1','Population 2'};

for pop = 1:2
    subplot(1,2,pop);
    drawSimplex(labs, [0.3 0.3 0.3], 'xy');
    if ~isempty(titleStr)
        title([titleStr, ' — ', titles_{pop}], 'FontSize',11,'Interpreter','latex');
    else
        title(titles_{pop}, 'FontSize',11,'Interpreter','latex');
    end
    hold on;
end

for i = 1:K
    [~, Xi, Yi] = xRepDyn2pop(C, x0_mat(i,:)', y0_mat(i,:)', tspan, dynOpts);

    % Pop 1 (left panel)
    subplot(1,2,1); hold on;
    tx = Xi(:,1); ty = Xi(:,2);
    plot(tx, ty, '-', 'Color', cmap(i,:), 'LineWidth', 1.2);
    plot(tx(1),  ty(1),  'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:),'MarkerSize',5);
    plot(tx(end),ty(end),'s','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:),'MarkerSize',7);

    % Pop 2 (right panel)
    subplot(1,2,2); hold on;
    tx2 = Yi(:,1); ty2 = Yi(:,2);
    plot(tx2, ty2, '-', 'Color', cmap(i,:), 'LineWidth', 1.2);
    plot(tx2(1),  ty2(1),  'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:),'MarkerSize',5);
    plot(tx2(end),ty2(end),'s','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:),'MarkerSize',7);
end

% Mark pure vertices in both panels (x1,x2): e1=(1,0), e2=(0,1), e3=(0,0)
V2d = [1,0;0,1;0,0];
for pop = 1:2
    subplot(1,2,pop); hold on;
    plot(V2d(:,1),V2d(:,2),'^k','MarkerFaceColor','k','MarkerSize',8,'LineWidth',1.2);
end

drawnow;
end
