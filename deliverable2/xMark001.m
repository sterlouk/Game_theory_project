% Script to simulate Markov dynamics and draw its state transition graph
% M  = number of centipede stages (must be even)
% T  = number of one-shot centipedes played
% p  = proportion of payoff received by terminating player
% N  = population size
% Tm = final time of simulating Markov dynamics
% s0 = initial Markov state (integer counts, must sum to N)

rng(42);
figDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end

% 1. p=3/4, M=4, T=10, N=10
M=4; T=10; p=3/4; N=10; Tm=100; s0=[3 4 3];
P=PStateTransitionGraph(p,M,T,N);
saveas(gcf, fullfile(figDir, 'mark_stategraph_p075.png'))
s=sMarkDyn(s0,p,M,T,N,P,Tm); figure; plot(s,'LineWidth',2)
legend('All-M/2','All-1','Grim'); title('MarkDyn: p=3/4, M=4, T=10, N=10')
saveas(gcf, fullfile(figDir, 'mark_timeseries_p075.png'))

% 2. p=3/5, M=4, T=10, N=10
p=3/5;
P=PStateTransitionGraph(p,M,T,N);
saveas(gcf, fullfile(figDir, 'mark_stategraph_p060.png'))
s=sMarkDyn(s0,p,M,T,N,P,Tm); figure; plot(s,'LineWidth',2)
legend('All-M/2','All-1','Grim'); title('MarkDyn: p=3/5, M=4, T=10, N=10')
saveas(gcf, fullfile(figDir, 'mark_timeseries_p060.png'))

% --- Overlay comparisons: vary one parameter at a time ---
strat = {'All-M/2','All-1','Grim'};
N0=10; Tm0=100; s0=[3 4 3];

% Vary p (M=4, T=10, N=10 fixed)
pvals = [3/5, 2/3, 3/4, 9/10];
trajectories = cell(length(pvals),1);
for i=1:length(pvals)
    Pi=PStateTransitionGraph(pvals(i),4,10,N0); close(gcf);
    trajectories{i}=sMarkDyn(s0,pvals(i),4,10,N0,Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(pvals),1);
    for i=1:length(pvals)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=sprintf('p=%.4g',pvals(i));
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('MarkDyn: vary p (M=4, T=10, N=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_p.png'))

% Vary M (p=3/4, T=10, N=10 fixed)
Mvals = [2, 4, 6, 8];
trajectories = cell(length(Mvals),1);
for i=1:length(Mvals)
    Pi=PStateTransitionGraph(3/4,Mvals(i),10,N0); close(gcf);
    trajectories{i}=sMarkDyn(s0,3/4,Mvals(i),10,N0,Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(Mvals),1);
    for i=1:length(Mvals)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=sprintf('M=%d',Mvals(i));
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('MarkDyn: vary M (p=3/4, T=10, N=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_M.png'))

% Vary T (p=3/4, M=4, N=10 fixed)
Tvals = [2, 5, 10, 20];
trajectories = cell(length(Tvals),1);
for i=1:length(Tvals)
    Pi=PStateTransitionGraph(3/4,4,Tvals(i),N0); close(gcf);
    trajectories{i}=sMarkDyn(s0,3/4,4,Tvals(i),N0,Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(Tvals),1);
    for i=1:length(Tvals)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=sprintf('T=%d',Tvals(i));
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('MarkDyn: vary T (p=3/4, M=4, N=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_T.png'))

% Vary N (p=3/4, M=4, T=10 fixed)
Nvals = [5, 10, 15, 20];
trajectories = cell(length(Nvals),1);
s0list = {[1 2 2], [3 4 3], [5 5 5], [7 7 6]};
for i=1:length(Nvals)
    Pi=PStateTransitionGraph(3/4,4,10,Nvals(i)); close(gcf);
    trajectories{i}=sMarkDyn(s0list{i},3/4,4,10,Nvals(i),Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(Nvals),1);
    for i=1:length(Nvals)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=sprintf('N=%d',Nvals(i));
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('MarkDyn: vary N (p=3/4, M=4, T=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_N.png'))

% Vary s0 (p=3/4, M=4, T=10, N=10 fixed)
s0list2 = {[8 1 1], [1 8 1], [1 1 8], [3 4 3]};
s0names = {'s0=[8,1,1] (mostly All-M/2)', ...
           's0=[1,8,1] (mostly All-1)', ...
           's0=[1,1,8] (mostly Grim)', ...
           's0=[3,4,3] (balanced)'};
Pi=PStateTransitionGraph(3/4,4,10,N0); close(gcf);
trajectories = cell(length(s0list2),1);
for i=1:length(s0list2)
    trajectories{i}=sMarkDyn(s0list2{i},3/4,4,10,N0,Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(s0list2),1);
    for i=1:length(s0list2)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=s0names{i};
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',6);
    hold off;
end
sgtitle('MarkDyn: vary s0 (p=3/4, M=4, T=10, N=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_s0_p075.png'))

% Vary s0 (p=3/5, M=4, T=10, N=10 fixed)
Pi=PStateTransitionGraph(3/5,4,10,N0); close(gcf);
trajectories = cell(length(s0list2),1);
for i=1:length(s0list2)
    trajectories{i}=sMarkDyn(s0list2{i},3/5,4,10,N0,Pi,Tm0);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(s0list2),1);
    for i=1:length(s0list2)
        plot(0:Tm0, trajectories{i}(:,k),'LineWidth',2);
        labels{i}=s0names{i};
    end
    title(strat{k}); xlabel('time step'); ylabel('count');
    legend(labels,'Location','best','FontSize',6);
    hold off;
end
sgtitle('MarkDyn: vary s0 (p=3/5, M=4, T=10, N=10)')
saveas(gcf, fullfile(figDir, 'mark_overlay_vary_s0_p060.png'))
