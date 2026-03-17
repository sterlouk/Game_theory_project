function PhasePlot(p, M, T)
% PHASEPLOT  Phase portrait of the ISC replicator dynamics on the 2-simplex.
%   Reproduces Figures 2-3 of Lazaridis-Kehagias.
%
%   Axes: x1 = All-M/2 (cooperator), x2 = All-1 (defector), x3 = Grim (implicit)
%
% Inputs:
%   p : terminator payoff share
%   M : number of centipede stages (must be even)
%   T : number of ISC rounds

    C  = buildC(p, M, T);

    %% Vector field
    n = 28;
    gv = linspace(0,1,n);
    [X1,X2] = meshgrid(gv,gv);
    U = nan(n,n);  V = nan(n,n);
    in = false(n,n);
    for i=1:n
        for j=1:n
            x3 = 1 - X1(i,j) - X2(i,j);
            if x3 < -1e-9, continue; end
            in(i,j) = true;
            x  = [X1(i,j); X2(i,j); max(x3,0)];
            x  = x/sum(x);
            dx = replicatorRHS(x,C);
            U(i,j) = dx(1);  V(i,j) = dx(2);
        end
    end
    mag = sqrt(U.^2+V.^2);  mx = max(mag(in));
    if mx>0, U(in)=U(in)/mx; V(in)=V(in)/mx; end

    figure; hold on;
    quiver(X1,X2,U*0.035,V*0.035,0,'Color',[0.85 0.1 0.1],'LineWidth',1.4,'MaxHeadSize',0.6);
    plot([0 1 0 0],[0 0 1 0],'k-','LineWidth',1.5);
    xlabel('x_1  (All-M/2, cooperator)','FontSize',11);
    ylabel('x_2  (All-1, defector)',    'FontSize',11);
    title(sprintf('Phase portrait — p=%.4g, M=%d, T=%d', p,M,T),'FontSize',12);
    xlim([-0.05 1.05]); ylim([-0.05 1.05]); axis equal; box on; hold off;
end

function dxdt = replicatorRHS(x, C)
    x    = max(x,0);  x = x/(sum(x)+eps);
    Cx   = C*x;
    dxdt = x .* (Cx - x'*Cx);
end

function C = buildC(p, M, T)
    k   = M/2;
    Akk = k;  Ak1 = 3*(1-p);  A1k = 3*p;  A11 = 1;
    AMM = M;  AkM = (2*k+1)*p;  AMk = (2*k+1)*(1-p);
    C = [ T*Akk,              T*Ak1,             AkM+(T-1)*Ak1 ;
          T*A1k,              T*A11,             A1k+(T-1)*A11 ;
          AMk+(T-1)*A1k,  Ak1+(T-1)*A11,             T*AMM ];
end
