% Script to simulate Replicator dynamics and draw its phase plot
% M  = number of centipede stages (must be even)
% T  = number of one-shot centipedes played
% p  = proportion of payoff received by terminating player
% Tf = final time of simulating replicator dynamics
% x0 = initial population frequencies (3-vector, normalised to sum to 1)

rng(42);
figDir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end

% 1. p=3/4, M=4, T=10
M=4; T=10; p=3/4; Tf=1;
x0=rand(3,1); x0=x0/sum(x0);
x=xRepDyn(x0,p,M,T,Tf); figure; plot(x','LineWidth',2)
legend('All-M/2','All-1','Grim'); title('RepDyn: p=3/4, M=4, T=10')
saveas(gcf, fullfile(figDir, 'rep_timeseries_p075.png'))
PhasePlot(p,M,T)
saveas(gcf, fullfile(figDir, 'rep_phase_p075.png'))

% 2. p=3/5, M=4, T=10
p=3/5;
x0=rand(3,1); x0=x0/sum(x0);
x=xRepDyn(x0,p,M,T,Tf); figure; plot(x','LineWidth',2)
legend('All-M/2','All-1','Grim'); title('RepDyn: p=3/5, M=4, T=10')
saveas(gcf, fullfile(figDir, 'rep_timeseries_p060.png'))
PhasePlot(p,M,T)
saveas(gcf, fullfile(figDir, 'rep_phase_p060.png'))

% --- Overlay comparisons: vary one parameter at a time ---
strat = {'All-M/2','All-1','Grim'};
Tf=1;

% Vary p (M=4, T=10 fixed)
pvals = [3/5, 2/3, 3/4, 9/10];
trajectories = cell(length(pvals),1);
for i=1:length(pvals)
    x0=rand(3,1); x0=x0/sum(x0);
    trajectories{i}=xRepDyn(x0,pvals(i),4,10,Tf);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(pvals),1);
    for i=1:length(pvals)
        t=linspace(0,Tf,size(trajectories{i},2));
        plot(t,trajectories{i}(k,:),'LineWidth',2);
        labels{i}=sprintf('p=%.4g',pvals(i));
    end
    title(strat{k}); xlabel('t'); ylabel('frequency');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('RepDyn: vary p (M=4, T=10)')
saveas(gcf, fullfile(figDir, 'rep_overlay_vary_p.png'))

% Vary M (p=3/4, T=10 fixed)
Mvals = [2, 4, 6, 8];
trajectories = cell(length(Mvals),1);
for i=1:length(Mvals)
    x0=rand(3,1); x0=x0/sum(x0);
    trajectories{i}=xRepDyn(x0,3/4,Mvals(i),10,Tf);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(Mvals),1);
    for i=1:length(Mvals)
        t=linspace(0,Tf,size(trajectories{i},2));
        plot(t,trajectories{i}(k,:),'LineWidth',2);
        labels{i}=sprintf('M=%d',Mvals(i));
    end
    title(strat{k}); xlabel('t'); ylabel('frequency');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('RepDyn: vary M (p=3/4, T=10)')
saveas(gcf, fullfile(figDir, 'rep_overlay_vary_M.png'))

% Vary T (p=3/4, M=4 fixed)
Tvals = [2, 5, 10, 20];
trajectories = cell(length(Tvals),1);
for i=1:length(Tvals)
    x0=rand(3,1); x0=x0/sum(x0);
    trajectories{i}=xRepDyn(x0,3/4,4,Tvals(i),Tf);
end
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(Tvals),1);
    for i=1:length(Tvals)
        t=linspace(0,Tf,size(trajectories{i},2));
        plot(t,trajectories{i}(k,:),'LineWidth',2);
        labels{i}=sprintf('T=%d',Tvals(i));
    end
    title(strat{k}); xlabel('t'); ylabel('frequency');
    legend(labels,'Location','best','FontSize',7);
    hold off;
end
sgtitle('RepDyn: vary T (p=3/4, M=4)')
saveas(gcf, fullfile(figDir, 'rep_overlay_vary_T.png'))

% Vary x0 (p=3/4, M=4, T=10 fixed)
x0list = {[0.8; 0.1; 0.1], [0.1; 0.8; 0.1], [0.1; 0.1; 0.8], [1/3; 1/3; 1/3]};
x0names = {'x0=[0.8,0.1,0.1] (mostly All-M/2)', ...
           'x0=[0.1,0.8,0.1] (mostly All-1)', ...
           'x0=[0.1,0.1,0.8] (mostly Grim)', ...
           'x0=[1/3,1/3,1/3] (uniform)'};
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(x0list),1);
    for i=1:length(x0list)
        xi=xRepDyn(x0list{i},3/4,4,10,Tf);
        t=linspace(0,Tf,size(xi,2));
        plot(t,xi(k,:),'LineWidth',2);
        labels{i}=x0names{i};
    end
    title(strat{k}); xlabel('t'); ylabel('frequency');
    legend(labels,'Location','best','FontSize',6);
    hold off;
end
sgtitle('RepDyn: vary x0 (p=3/4, M=4, T=10)')
saveas(gcf, fullfile(figDir, 'rep_overlay_vary_x0_p075.png'))

% Vary x0 (p=3/5, M=4, T=10 fixed)
figure; set(gcf,'Position',[100 100 1200 400]);
for k=1:3
    subplot(1,3,k); hold on;
    labels = cell(length(x0list),1);
    for i=1:length(x0list)
        xi=xRepDyn(x0list{i},3/5,4,10,Tf);
        t=linspace(0,Tf,size(xi,2));
        plot(t,xi(k,:),'LineWidth',2);
        labels{i}=x0names{i};
    end
    title(strat{k}); xlabel('t'); ylabel('frequency');
    legend(labels,'Location','best','FontSize',6);
    hold off;
end
sgtitle('RepDyn: vary x0 (p=3/5, M=4, T=10)')
saveas(gcf, fullfile(figDir, 'rep_overlay_vary_x0_p060.png'))

% Rest points analysis -- print to console and save to file
fprintf('\n========== Rest Points Analysis ==========\n')
rpText = '';
rpText = [rpText, evalc('RestPoints(3/4, 4, 10)')];
rpText = [rpText, evalc('RestPoints(3/5, 4, 10)')];
for i=1:length(pvals)
    rpText = [rpText, evalc('RestPoints(pvals(i), 4, 10)')];
end
for i=1:length(Mvals)
    rpText = [rpText, evalc('RestPoints(3/4, Mvals(i), 10)')];
end
for i=1:length(Tvals)
    rpText = [rpText, evalc('RestPoints(3/4, 4, Tvals(i))')];
end
fprintf('%s', rpText);
fid = fopen(fullfile(figDir, 'restpoints.txt'), 'w');
fprintf(fid, '%s', rpText);
fclose(fid);
fprintf('Rest points saved to %s\n', fullfile(figDir, 'restpoints.txt'));
