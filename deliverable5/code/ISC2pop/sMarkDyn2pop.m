function [Xhist, Yhist] = sMarkDyn2pop(C, N1, N2, s0, t0, nSteps)
% SMARKDYN2POP  Simulate the two-population ISC Markov chain via direct sampling.
%
%   [Xhist, Yhist] = sMarkDyn2pop(C, N1, N2, s0, t0, nSteps)
%
%   TWO-POPULATION setup:
%     - Population 1: N1 players with state s=(s1,s2,s3), sum=N1.
%     - Population 2: N2 players with state t=(t1,t2,t3), sum=N2.
%     - Every pop-1 player plays against every pop-2 player (NO within-pop games).
%
%   Per-player payoffs:
%     Pop-1 strategy m: q_m^(1) = sum_n  t_n * C(m,n)
%     Pop-2 strategy n: q_n^(2) = sum_m  s_m * C(m,n)   [col player: C^T(n,m)=C(m,n)]
%
%   Revision protocol: PPI (Pairwise Proportional Imitation) within each pop.
%   At each step, select a population uniformly (50/50), then one player from
%   that population; that player may imitate within its own population.
%
%   Arguments:
%     C      - 3x3 ISC payoff matrix
%     N1,N2  - population sizes
%     s0     - 1x3 initial state for pop 1  (must sum to N1)
%     t0     - 1x3 initial state for pop 2  (must sum to N2)
%     nSteps - number of Markov steps
%
%   Returns:
%     Xhist  - (nSteps+1 x 3) pop-1 frequency history
%     Yhist  - (nSteps+1 x 3) pop-2 frequency history

s = s0(:)';  assert(sum(s)==N1 && numel(s)==3);
t = t0(:)';  assert(sum(t)==N2 && numel(t)==3);

Xhist = zeros(nSteps+1, 3);
Yhist = zeros(nSteps+1, 3);
Xhist(1,:) = s/N1;
Yhist(1,:) = t/N2;

for step = 1:nSteps
    % --- per-player payoffs (cross-population, no self-interaction) ---
    q1 = (C  * t')';   % 1x3: pop-1 strategy payoffs  = sum_n t_n * C(m,n)
    q2 = (C' * s')';   % 1x3: pop-2 strategy payoffs  = sum_m s_m * C(m,n)

    % --- choose which population updates (50/50) ----------------------
    if rand() < 0.5
        % Update pop 1
        [s, ~] = ppiStep(s, q1, N1);
    else
        % Update pop 2
        [t, ~] = ppiStep(t, q2, N2);
    end

    Xhist(step+1,:) = s/N1;
    Yhist(step+1,:) = t/N2;
end
end

% -----------------------------------------------------------------------
function [s_new, switched] = ppiStep(s, q, N)
% One PPI step: select a player in population s, possibly switch strategy.
% q(m) = payoff of strategy m; N = total players.

switched = false;
x = s/N;

% Select player (strategy m1) proportional to frequency
r  = rand();
cs = cumsum(x);
m1 = find(cs >= r, 1, 'first');
if isempty(m1) || s(m1)==0
    s_new = s; return;
end

% Compute surplus of each strategy over m1
surplus = max(q - q(m1), 0);   % 1x3
surplus(m1) = 0;
denom   = sum(x .* surplus);

if denom < 1e-14
    s_new = s; return;
end

% Choose target strategy m2 proportional to x_{m2}*[q_{m2}-q_{m1}]+
probs = x .* surplus / denom;
r2    = rand();
cs2   = cumsum(probs);
m2    = find(cs2 >= r2, 1, 'first');

if isempty(m2) || m2 == m1 || s(m2) == 0
    s_new = s; return;
end

s_new     = s;
s_new(m1) = s_new(m1) - 1;
s_new(m2) = s_new(m2) + 1;
switched  = true;
end
