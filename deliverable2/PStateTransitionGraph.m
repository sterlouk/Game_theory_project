function P = PStateTransitionGraph(p, M, T, N)
% PSTATETRANSITIONGRAPH  Build ISC Markov transition matrix and plot graph.
%   Reproduces Figures 4-5 of Lazaridis-Kehagias.
%
%   State (s1,s2,s3): s1+s2+s3=N
%     s1 = # sigma_All-M/2  (cooperator)
%     s2 = # sigma_All-1    (defector)
%     s3 = # sigma_G = Grim
%   Mapped to point (s1,s2) in the plot.
%   Blue dots = absorbing states (pure states only); red dots = transient.
%
% Inputs:
%   p, M, T : ISC parameters (M must be even)
%   N       : population size
%
% Output:
%   P : (nStates x nStates) row-stochastic transition matrix (for sMarkDyn)

    C = buildC(p, M, T);
    [states, lut] = listStates(N);
    nS = size(states,1);
    THRESH = 1e-12;

    %% Build P
    P = zeros(nS, nS);
    for idx = 1:nS
        s      = states(idx,:);
        q      = perPlayerPayoff(s, C);
        p_self = 1;
        for m1 = 1:3
            if s(m1)==0, continue; end
            w = zeros(3,1);
            for m2=1:3
                if m2==m1, continue; end
                w(m2) = (s(m2)/N) * max(q(m2)-q(m1), 0);
            end
            tw = sum(w);
            if tw < THRESH, continue; end
            for m2=1:3
                if m2==m1 || w(m2)<THRESH, continue; end
                sn = s;  sn(m1)=sn(m1)-1;  sn(m2)=sn(m2)+1;
                jdx = lut(sn(1)+1, sn(2)+1);
                tp  = (s(m1)/N) * (w(m2)/tw);
                P(idx,jdx) = P(idx,jdx) + tp;
                p_self = p_self - tp;
            end
        end
        P(idx,idx) = P(idx,idx) + p_self;
    end
    rs = sum(P,2);
    for i=1:nS, if rs(i)>0, P(i,:)=P(i,:)/rs(i); end; end

    %% Plot
    figure; hold on;
    for idx = 1:nS
        s = states(idx,:);
        q = perPlayerPayoff(s, C);
        for m1=1:3
            if s(m1)==0, continue; end
            w = zeros(3,1);
            for m2=1:3
                if m2==m1, continue; end
                w(m2) = (s(m2)/N)*max(q(m2)-q(m1),0);
            end
            tw = sum(w);
            if tw<THRESH, continue; end
            for m2=1:3
                if m2==m1 || w(m2)<THRESH, continue; end
                sn=s; sn(m1)=sn(m1)-1; sn(m2)=sn(m2)+1;
                quiver(s(1),s(2),(sn(1)-s(1))*0.72,(sn(2)-s(2))*0.72,0,...
                    'k','MaxHeadSize',0.6,'LineWidth',0.9);
            end
        end
    end
    for idx=1:nS
        s=states(idx,:);
        isPure = sum(s>0)==1;   % only one strategy present => truly absorbing
        if isPure
            plot(s(1),s(2),'b.','MarkerSize',14);
        else
            plot(s(1),s(2),'r.','MarkerSize',14);
        end
        text(s(1)+0.12,s(2)+0.12,num2str(idx),'FontSize',5.5,'Color',[.3 .3 .3]);
    end
    xlabel('s_1  (# All-M/2, cooperator)','FontSize',11);
    ylabel('s_2  (# All-1, defector)',     'FontSize',11);
    title(sprintf('Replicator Markov — p=%.4g, M=%d, T=%d, N=%d',p,M,T,N),'FontSize',12);
    xlim([-0.5 N+0.5]); ylim([-0.5 N+0.5]); axis equal; box on; hold off;
end

% ------------------------------------------------------------------
function q = perPlayerPayoff(s, C)
    s = s(:);  q = zeros(3,1);
    for m=1:3
        if s(m)==0, continue; end
        acc = (s(m)-1)*C(m,m);
        for n=1:3
            if n~=m, acc = acc + s(n)*C(m,n); end
        end
        q(m) = acc;
    end
end

function [states, lut] = listStates(N)
    states = zeros((N+1)*(N+2)/2, 3);
    lut    = zeros(N+1, N+1);
    row = 0;
    for s1=0:N
        for s2=0:N-s1
            row = row+1;
            states(row,:)      = [s1, s2, N-s1-s2];
            lut(s1+1, s2+1)    = row;
        end
    end
end

function C = buildC(p, M, T)
    k   = M/2;
    Akk = k;  Ak1 = 3*(1-p);  A1k = 3*p;  A11 = 1;
    AMM = M;  AkM = (2*k+1)*p;  AMk = (2*k+1)*(1-p);
    C = [ T*Akk,              T*Ak1,             AkM+(T-1)*Ak1 ;
          T*A1k,              T*A11,             A1k+(T-1)*A11 ;
          AMk+(T-1)*A1k,  Ak1+(T-1)*A11,             T*AMM ];
end
