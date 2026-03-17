function RestPoints(p, M, T)
% RESTPOINTS  Find all rest points of the ISC replicator dynamics and
%   classify their stability.
%
%   Strategies:
%     1 = sigma_All-M/2  (cooperator)
%     2 = sigma_All-1    (defector)
%     3 = sigma_G = Grim
%
% Inputs:
%   p : terminator payoff share, p in (0.5, 1]
%   M : number of centipede stages (must be even)
%   T : number of ISC rounds

    C = buildC(p, M, T);
    names = {'All-M/2','All-1','Grim'};
    tol = 1e-10;

    fprintf('\n===== Rest Points for p=%g, M=%d, T=%d =====\n\n', p, M, T);

    % 1. Pure strategy vertices (always rest points)
    for i = 1:3
        ei = zeros(3,1); ei(i) = 1;
        stab = classifyVertex(C, i);
        fprintf('Pure: %s  (%s)\n', names{i}, stab);
    end

    % 2. Edge equilibria (two strategies coexist, third extinct)
    edges = [1 2; 1 3; 2 3];
    for e = 1:3
        i = edges(e,1); j = edges(e,2);
        % Solve: (C(i,:)-C(j,:))*x = 0 with x(i)+x(j)=1, x(k)=0
        k = setdiff(1:3, [i j]);
        d = C(i,:) - C(j,:);    % d*x = 0
        % d(i)*x(i) + d(j)*x(j) = 0  and  x(i)+x(j) = 1
        % => x(j) = -d(i)/(d(j)-d(i)),  x(i) = d(j)/(d(j)-d(i))
        denom = d(j) - d(i);
        if abs(denom) < tol, continue; end
        xi = d(j) / denom;
        xj = -d(i) / denom;
        if xi < tol || xi > 1-tol || xj < tol || xj > 1-tol
            continue;   % not in the interior of the edge
        end
        xeq = zeros(3,1); xeq(i) = xi; xeq(j) = xj;
        stab = classifyEdge(C, xeq, i, j, k);
        fprintf('Edge: %s=%.4f, %s=%.4f  (%s)\n', ...
            names{i}, xi, names{j}, xj, stab);
    end

    % 3. Interior equilibrium (all three strategies coexist)
    % Solve: (C(1,:)-C(2,:))*x = 0, (C(2,:)-C(3,:))*x = 0, sum(x)=1
    A = [C(1,:)-C(2,:); C(2,:)-C(3,:); 1 1 1];
    b = [0; 0; 1];
    if abs(det(A)) > tol
        xint = A \ b;
        if all(xint > tol)
            stab = classifyInterior(C, xint);
            fprintf('Interior: %s=%.4f, %s=%.4f, %s=%.4f  (%s)\n', ...
                names{1}, xint(1), names{2}, xint(2), names{3}, xint(3), stab);
        end
    end

    fprintf('\n');
end

% ------------------------------------------------------------------
function stab = classifyVertex(C, i)
    % At vertex e_i, the other strategies invade if C(j,i) > C(i,i)
    others = setdiff(1:3, i);
    invading = false(1,2);
    for idx = 1:2
        j = others(idx);
        invading(idx) = C(j,i) > C(i,i);
    end
    if ~any(invading)
        stab = 'stable (ESS)';
    elseif all(invading)
        stab = 'unstable';
    else
        stab = 'saddle';
    end
end

% ------------------------------------------------------------------
function stab = classifyEdge(C, xeq, i, j, k)
    % Jacobian of 2D replicator on the edge {i,j} plus transversal direction
    % Tangent stability: d/dx_i of the replicator along the edge
    Cx = C * xeq;
    fi = Cx(i); fj = Cx(j);
    fbar = xeq' * Cx;

    % Tangent eigenvalue (along the edge)
    % For 2-strategy replicator x_i' = x_i((Cx)_i - fbar)
    % linearise at equilibrium: lambda_tan ~ x_i*(C(i,i)-C(j,i)) + x_j*(C(i,j)-C(j,j))
    % More precisely, partial derivative of x_i*((Cx)_i - fbar) w.r.t. x_i
    % on the edge x_j = 1 - x_i:
    dCx_i = C(i,i) - C(i,j);   % d(Cx)_i/dx_i on edge
    dCx_j = C(j,i) - C(j,j);
    dfbar = xeq(i)*(dCx_i) + (Cx(i)-Cx(j)) + xeq(j)*(dCx_j) ...
            - xeq(i)*(dCx_i) - xeq(j)*(dCx_j);
    % Simplified: on the edge, lambda_tan = x_i*x_j*(dCx_i - dCx_j) sign
    % Use finite-difference-free formula:
    lam_tan = xeq(i)*( (C(i,i)-C(j,i)) - (C(i,j)-C(j,j)) ) * (-xeq(j)) ...
            + xeq(i)*((C(i,:)-C(j,:))*(C(i,:)-C(j,:))');
    % Actually, let's just use the direct Jacobian numerically
    eps_val = 1e-7;
    xp = xeq; xp(i) = xp(i)+eps_val; xp(j) = xp(j)-eps_val;
    dxp = repRHS(xp, C);
    xm = xeq; xm(i) = xm(i)-eps_val; xm(j) = xm(j)+eps_val;
    dxm = repRHS(xm, C);
    lam_tan = (dxp(i) - dxm(i)) / (2*eps_val);

    % Transversal eigenvalue (does strategy k invade?)
    lam_trans = Cx(k) - fbar;

    if lam_tan < -1e-9 && lam_trans < -1e-9
        stab = 'stable';
    elseif lam_tan > 1e-9 && lam_trans > 1e-9
        stab = 'unstable';
    else
        stab = 'saddle';
    end
end

% ------------------------------------------------------------------
function stab = classifyInterior(C, xeq)
    % Numerical Jacobian of the replicator on the simplex (2D)
    % Use coordinates (x1, x2), x3 = 1 - x1 - x2
    eps_val = 1e-7;
    J = zeros(2,2);
    for col = 1:2
        xp = xeq; xp(col) = xp(col)+eps_val; xp(3) = 1-xp(1)-xp(2);
        xm = xeq; xm(col) = xm(col)-eps_val; xm(3) = 1-xm(1)-xm(2);
        dp = repRHS(xp, C);
        dm = repRHS(xm, C);
        J(:,col) = (dp(1:2) - dm(1:2)) / (2*eps_val);
    end
    ev = eig(J);
    if all(real(ev) < -1e-9)
        stab = 'stable';
    elseif all(real(ev) > 1e-9)
        stab = 'unstable';
    else
        stab = 'saddle';
    end
end

% ------------------------------------------------------------------
function dxdt = repRHS(x, C)
    x    = max(x,0); x = x/(sum(x)+eps);
    Cx   = C*x;
    dxdt = x .* (Cx - x'*Cx);
end

% ------------------------------------------------------------------
function C = buildC(p, M, T)
    k   = M/2;
    Akk = k;  Ak1 = 3*(1-p);  A1k = 3*p;  A11 = 1;
    AMM = M;  AkM = (2*k+1)*p;  AMk = (2*k+1)*(1-p);
    C = [ T*Akk,              T*Ak1,             AkM+(T-1)*Ak1 ;
          T*A1k,              T*A11,             A1k+(T-1)*A11 ;
          AMk+(T-1)*A1k,  Ak1+(T-1)*A11,             T*AMM ];
end
