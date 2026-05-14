% xMark2pop001.m
% =============================================================
% Main script: Two-Population ISC Markov Chain Dynamics
% Generates all Markov figures for the paper.
%
% TWO-POPULATION setup:
%   Pop 1 (N1 players) vs Pop 2 (N2 players).
%   Every pop-1 player plays every pop-2 player once.
%   NO within-population games.
%   Payoffs: q_m^(1) = sum_n t_n*C(m,n)
%            q_n^(2) = sum_m s_m*C(m,n)
%   Revision: PPI within each population.
% =============================================================

clear; close all;
if ~exist('figures','dir'), mkdir('figures'); end

M=4; T=10; N1=10; N2=10; nSteps=5000;
mu = 1e-3;  % small exploration to avoid immediate flat absorption in time series
cols  = lines(3);
names = {'All-$M$','All-$1$','Grim'};
rng(7);

% =============================================================
% State transition graphs (small N for legibility)
% =============================================================
Ng = 5;  % use N=5 for graph visualisation
for p = [3/4, 3/5]
    C    = computeC(M, T, p);
    pStr = strrep(num2str(p,'%.2f'),'.','');
    PStateTransitionGraph2pop(C, Ng, Ng, sprintf('$p=%.2f$', p));
    saveas(gcf, sprintf('figures/mark_stategraph_p%s.png', pStr));
    fprintf('Saved mark_stategraph_p%s.png\n', pStr);
end

% =============================================================
% Helper: run simulation and plot time series (both populations)
% =============================================================
function plotMarkTS(C, N1, N2, s0, t0, nSteps, mu, cols, names, ttl, fname)
    [Xh, Yh] = sMarkDyn2pop(C, N1, N2, s0, t0, nSteps, mu);
    figure('Units','centimeters','Position',[2 2 26 10]);
    for pop = 1:2
        subplot(1,2,pop);
        Z = {Xh,Yh}; Zp=Z{pop};
        for m=1:3
            plot(Zp(:,m),'-','Color',cols(m,:),'LineWidth',1.3); hold on;
        end
        xlabel('Step','Interpreter','latex');
        ylabel('Frequency','Interpreter','latex');
        title(sprintf('%s — Pop %d', ttl, pop),'Interpreter','latex','FontSize',10);
        legend(names,'Interpreter','latex','Location','best','FontSize',8);
        ylim([0 1]); grid on;
    end
    if ~isempty(fname), saveas(gcf,[fname,'.png']); end
end

% =============================================================
% Time series: p=3/4 and p=3/5
% =============================================================
s0 = [3 4 3]; t0 = [4 3 3];
for p = [3/4, 3/5]
    C    = computeC(M,T,p);
    pStr = strrep(num2str(p,'%.2f'),'.','');
    plotMarkTS(C,N1,N2,s0,t0,nSteps,mu,cols,names,...
               sprintf('$p=%.2f$',p),...
               sprintf('figures/mark_timeseries_p%s',pStr));
    fprintf('Saved mark_timeseries_p%s.png\n',pStr);
end

% =============================================================
% Vary p
% =============================================================
pVals = [3/5, 2/3, 3/4, 9/10];
figure('Units','centimeters','Position',[2 2 28 18]);
for pi_=1:numel(pVals)
    p=pVals(pi_); C=computeC(M,T,p);
    [Xh,Yh]=sMarkDyn2pop(C,N1,N2,s0,t0,nSteps,mu);
    for m=1:3
        subplot(3,4,(m-1)*4+pi_);
        plot(Xh(:,m),'-','Color',cols(m,:),'LineWidth',1.2); hold on;
        plot(Yh(:,m),'--','Color',cols(m,:),'LineWidth',0.9);
        if m==1, title(sprintf('$p=%.2f$',p),'Interpreter','latex','FontSize',9); end
        if pi_==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
subplot(3,4,1); legend({'Pop1','Pop2'},'FontSize',8,'Location','ne');
sgtitle('Effect of $p$ (solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/mark_overlay_vary_p.png');

% =============================================================
% Vary M
% =============================================================
p=3/4; MVals=[2 4 6 8];
figure('Units','centimeters','Position',[2 2 28 18]);
for mi=1:numel(MVals)
    M_=MVals(mi); C=computeC(M_,T,p);
    [Xh,Yh]=sMarkDyn2pop(C,N1,N2,s0,t0,nSteps,mu);
    for m=1:3
        subplot(3,4,(m-1)*4+mi);
        plot(Xh(:,m),'-','Color',cols(m,:),'LineWidth',1.2); hold on;
        plot(Yh(:,m),'--','Color',cols(m,:),'LineWidth',0.9);
        if m==1, title(sprintf('$M=%d$',M_),'Interpreter','latex','FontSize',9); end
        if mi==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
sgtitle('Effect of $M$ ($p=3/4$, solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/mark_overlay_vary_M.png');

% =============================================================
% Vary T
% =============================================================
M=4; TVals=[2 5 10 20];
figure('Units','centimeters','Position',[2 2 28 18]);
for ti=1:numel(TVals)
    T_=TVals(ti); C=computeC(M,T_,p);
    [Xh,Yh]=sMarkDyn2pop(C,N1,N2,s0,t0,nSteps,mu);
    for m=1:3
        subplot(3,4,(m-1)*4+ti);
        plot(Xh(:,m),'-','Color',cols(m,:),'LineWidth',1.2); hold on;
        plot(Yh(:,m),'--','Color',cols(m,:),'LineWidth',0.9);
        if m==1, title(sprintf('$T=%d$',T_),'Interpreter','latex','FontSize',9); end
        if ti==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
sgtitle('Effect of $T$ ($p=3/4$, $M=4$, solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/mark_overlay_vary_T.png');

% =============================================================
% Vary N
% =============================================================
T=10; NVals=[5 10 15 20];
figure('Units','centimeters','Position',[2 2 28 18]);
for ni=1:numel(NVals)
    Ni=NVals(ni);
    s0i=round(Ni*[0.3 0.4 0.3]); s0i(3)=Ni-s0i(1)-s0i(2);
    t0i=round(Ni*[0.4 0.3 0.3]); t0i(3)=Ni-t0i(1)-t0i(2);
    C=computeC(M,T,p);
    [Xh,Yh]=sMarkDyn2pop(C,Ni,Ni,s0i,t0i,nSteps,mu);
    for m=1:3
        subplot(3,4,(m-1)*4+ni);
        plot(Xh(:,m),'-','Color',cols(m,:),'LineWidth',1.2); hold on;
        plot(Yh(:,m),'--','Color',cols(m,:),'LineWidth',0.9);
        if m==1, title(sprintf('$N=%d$',Ni),'Interpreter','latex','FontSize',9); end
        if ni==1, ylabel(names{m},'Interpreter','latex','FontSize',9); end
        ylim([0 1]); grid on;
    end
end
sgtitle('Effect of $N$ ($p=3/4$, $M=4$, $T=10$, solid=Pop1, dashed=Pop2)',...
        'Interpreter','latex','FontSize',11);
saveas(gcf,'figures/mark_overlay_vary_N.png');

% =============================================================
% Vary initial state s0, t0
% =============================================================
M=4; T=10; N1=10; N2=10;
ic_list = {[7,2,1],[1,8,1],[1,2,7],[4,3,3],[3,4,3],[3,3,4],[5,5,0],[5,0,5],[0,5,5]};
for p=[3/4,3/5]
    C=computeC(M,T,p);
    pStr=strrep(num2str(p,'%.2f'),'.','');
    figure('Units','centimeters','Position',[2 2 28 18]);
    nIC2=numel(ic_list);
    for ki=1:nIC2
        ic=ic_list{ki}; ic=round(ic/sum(ic)*N1);
        ic(3)=N1-ic(1)-ic(2);
        [Xh,Yh]=sMarkDyn2pop(C,N1,N2,ic,ic,nSteps,mu);
        for m=1:3
            subplot(3,nIC2,(m-1)*nIC2+ki);
            plot(Xh(:,m),'-','Color',cols(m,:),'LineWidth',1.1); hold on;
            plot(Yh(:,m),'--','Color',cols(m,:),'LineWidth',0.8);
            ylim([0 1]); grid on;
            if m==1, title(sprintf('[%d,%d,%d]',ic(1),ic(2),ic(3)),'FontSize',7); end
            if ki==1, ylabel(names{m},'Interpreter','latex','FontSize',8); end
        end
    end
    sgtitle(sprintf('IC sensitivity ($p=%.2f$, solid=Pop1, dashed=Pop2)',p),...
            'Interpreter','latex','FontSize',10);
    saveas(gcf,sprintf('figures/mark_overlay_vary_s0_p%s.png',pStr));
end

fprintf('\nAll Markov figures saved to figures/\n');
