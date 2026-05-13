% xRep2pop001.m
% =============================================================
% Main script: Two-Population ISC Replicator Dynamics
% Reproduces Figures 2-3 (phase portraits) and provides
% parameter sensitivity analysis for the paper.
%
% Parameters follow the original Lazaridis-Kehagias (2026) paper:
%   Strategies: 1=All-M, 2=All-1, 3=Grim
%   Default: M=4, T=10, p=3/4 and p=3/5
% =============================================================

clear; close all;
if ~exist('figures','dir'), mkdir('figures'); end

M = 4;  T = 10;
nIC = 20;   % number of random initial conditions
rng(42);

% ---------------------------------------------------------------
% Helper: random initial condition pair on 3-simplex
randIC = @() [rand(1,2), 0];  % will be normalised inside xRepDyn2pop
function z = randSimplex3()
    r = sort(rand(1,2));
    z = [r(1), r(2)-r(1), 1-r(2)];
end

% Generate random initial conditions
x0s = zeros(nIC,3);  y0s = zeros(nIC,3);
for k=1:nIC
    x0s(k,:) = randSimplex3();
    y0s(k,:) = randSimplex3();
end

% =============================================================
% Figures 2-3: Phase portraits for p=3/4 and p=3/5
% =============================================================
for p = [3/4, 3/5]
    C = computeC(M, T, p);
    pStr = strrep(num2str(p,'%.2f'),'.','');
    
    PhasePlot2pop(C, x0s, y0s, [0 80], sprintf('$p = %.2f$', p));
    fname = sprintf('figures/rep_phase_p%s', pStr);
    saveas(gcf, [fname, '.png']);
    fprintf('Saved %s.png\n', fname);
end

% =============================================================
% Time series: a few trajectories for p=3/4 and p=3/5
% =============================================================
cols  = lines(3);
names = {'All-$M$','All-$1$','Grim'};
tspan = linspace(0,80,500);

for p = [3/4, 3/5]
    C    = computeC(M, T, p);
    pStr = strrep(num2str(p,'%.2f'),'.','');

    % One representative trajectory (asymmetric IC to show asymmetric behaviour)
    x0 = [0.6, 0.2, 0.2];
    y0 = [0.1, 0.1, 0.8];

    [t, X, Y] = xRepDyn2pop(C, x0', y0', tspan);

    figure('Units','centimeters','Position',[2 2 26 10]);
    for pop = 1:2
        subplot(1,2,pop);
        Z = {X, Y}; Zp = Z{pop};
        for m = 1:3
            plot(t, Zp(:,m), '-', 'Color', cols(m,:), 'LineWidth', 1.5); hold on;
        end
        xlabel('$t$','Interpreter','latex');
        ylabel('Frequency','Interpreter','latex');
        title(sprintf('Pop %d — $p=%.2f$', pop, p), 'Interpreter','latex','FontSize',11);
        legend(names,'Interpreter','latex','Location','best','FontSize',9);
        ylim([0 1]); grid on;
    end
    fname = sprintf('figures/rep_timeseries_p%s', pStr);
    saveas(gcf, [fname, '.png']);
    fprintf('Saved %s.png\n', fname);
end

% =============================================================
% Parameter sensitivity: vary p
% =============================================================
pVals = [3/5, 2/3, 3/4, 9/10];
x0 = [0.4 0.3 0.3];  y0 = [0.3 0.4 0.3];

figure('Units','centimeters','Position',[2 2 28 18]);
for pi_ = 1:numel(pVals)
    p  = pVals(pi_);
    C  = computeC(M, T, p);
    [t, X, Y] = xRepDyn2pop(C, x0', y0', tspan);
    for m = 1:3
        % Pop 1
        subplot(3,4, (m-1)*4+pi_);
        plot(t, X(:,m), '-', 'Color', cols(m,:), 'LineWidth', 1.4); hold on;
        plot(t, Y(:,m), '--','Color', cols(m,:), 'LineWidth', 1.0);
        if m==1, title(sprintf('$p=%.2f$',p),'Interpreter','latex','FontSize',9); end
        if pi_==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
        if m==3, xlabel('$t$','Interpreter','latex'); end
    end
end
% Shared legend
subplot(3,4,1);
legend({'Pop 1','Pop 2'},'Location','northeast','FontSize',8);
sgtitle('Effect of $p$ on replicator dynamics (solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/rep_overlay_vary_p.png');

% =============================================================
% Parameter sensitivity: vary M
% =============================================================
p = 3/4;
MVals = [2 4 6 8];
figure('Units','centimeters','Position',[2 2 28 18]);
for mi = 1:numel(MVals)
    M_ = MVals(mi);
    C  = computeC(M_, T, p);
    [t, X, Y] = xRepDyn2pop(C, x0', y0', tspan);
    for m = 1:3
        subplot(3,4,(m-1)*4+mi);
        plot(t,X(:,m),'-','Color',cols(m,:),'LineWidth',1.4); hold on;
        plot(t,Y(:,m),'--','Color',cols(m,:),'LineWidth',1.0);
        if m==1, title(sprintf('$M=%d$',M_),'Interpreter','latex','FontSize',9); end
        if mi==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
sgtitle('Effect of $M$ ($p=3/4$, solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/rep_overlay_vary_M.png');

% =============================================================
% Parameter sensitivity: vary T
% =============================================================
M = 4;
TVals = [2 5 10 20];
figure('Units','centimeters','Position',[2 2 28 18]);
for ti = 1:numel(TVals)
    T_ = TVals(ti);
    C  = computeC(M, T_, p);
    [t, X, Y] = xRepDyn2pop(C, x0', y0', tspan);
    for m = 1:3
        subplot(3,4,(m-1)*4+ti);
        plot(t,X(:,m),'-','Color',cols(m,:),'LineWidth',1.4); hold on;
        plot(t,Y(:,m),'--','Color',cols(m,:),'LineWidth',1.0);
        if m==1, title(sprintf('$T=%d$',T_),'Interpreter','latex','FontSize',9); end
        if ti==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
sgtitle('Effect of $T$ ($p=3/4$, $M=4$, solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/rep_overlay_vary_T.png');

% =============================================================
% Initial condition sensitivity
% =============================================================
M=4; T=10;
ic_list = {[1,0,0],[0,1,0],[0,0,1],[0.33,0.33,0.34],...
           [0.6,0.2,0.2],[0.2,0.6,0.2],[0.2,0.2,0.6],...
           [0.5,0.5,0],[0.5,0,0.5],[0,0.5,0.5]};

for p = [3/4, 3/5]
    C    = computeC(M,T,p);
    pStr = strrep(num2str(p,'%.2f'),'.','');
    figure('Units','centimeters','Position',[2 2 28 18]);
    for k = 1:min(numel(ic_list),8)
        ic = ic_list{k};
        ic = ic/sum(ic);
        % Symmetric IC: same for both populations
        [t,X,Y] = xRepDyn2pop(C, ic', ic', tspan);
        for m=1:3
            subplot(3,8,(m-1)*8+k);
            plot(t,X(:,m),'-','Color',cols(m,:),'LineWidth',1.2); hold on;
            plot(t,Y(:,m),'--','Color',cols(m,:),'LineWidth',0.8);
            ylim([0 1]); grid on;
            if m==1, title(sprintf('[%.1f,%.1f,%.1f]',ic(1),ic(2),ic(3)),...
                           'FontSize',7); end
            if k==1, ylabel(names{m},'Interpreter','latex','FontSize',8); end
        end
    end
    sgtitle(sprintf('IC sensitivity ($p=%.2f$, solid=Pop1, dashed=Pop2)',p),...
            'Interpreter','latex','FontSize',10);
    saveas(gcf,sprintf('figures/rep_overlay_vary_x0_p%s.png',pStr));
end

M=4; T=10;
fprintf('\nAll replicator dynamics figures saved to figures/\n');
