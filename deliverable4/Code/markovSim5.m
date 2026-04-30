function [freq_history, state_history] = markovSim5(C, N, s0, nSteps)
% MARKOVSIM5  Simulate the 5-strategy ISC Markov chain via direct sampling.
%
%   [freq_history, state_history] = markovSim5(C, N, s0, nSteps)
%
%   Uses the Pairwise Proportional Imitation (PPI) revision protocol:
%   at each step one player is selected uniformly at random; if a
%   beneficial switch is possible the player imitates proportionally.
%
%   Arguments:
%     C        - 5x5 payoff matrix
%     N        - number of players
%     s0       - 1x5 initial state (must sum to N)
%     nSteps   - number of Markov steps to simulate
%
%   Returns:
%     freq_history  - (nSteps+1) x 5  strategy frequency at each step
%     state_history - (nSteps+1) x 5  integer population state at each step

K = size(C, 1);

s = s0(:)';                          % ensure row
assert(sum(s) == N, 'sum(s0) must equal N');
assert(numel(s) == K, 'length of s0 must equal K=5');

freq_history  = zeros(nSteps+1, K);
state_history = zeros(nSteps+1, K);
freq_history(1,:)  = s / N;
state_history(1,:) = s;

for step = 1:nSteps
    % Per-player payoffs
    q = zeros(1, K);
    for m = 1:K
        if s(m) == 0
            q(m) = -Inf;
        else
            q(m) = (s(m)-1)*C(m,m) + sum(s.*C(m,:)) - s(m)*C(m,m);
        end
    end

    x = s / N;

    % Select a player uniformly (encoded as strategy m1 with prob s(m1)/N)
    r  = rand();
    cs = cumsum(x);
    m1 = find(cs >= r, 1, 'first');

    % Compute surpluses and switching probabilities
    surplus = max(q - q(m1), 0);
    surplus(m1) = 0;
    denom = sum(x .* surplus);

    if denom < 1e-14
        % No beneficial switch; state unchanged
        freq_history(step+1,:)  = s / N;
        state_history(step+1,:) = s;
        continue;
    end

    % Cumulative switching probabilities to choose m2
    probs = x .* surplus / denom;   % rho_{m1,m2} for each m2
    r2    = rand();
    cs2   = cumsum(probs);
    m2    = find(cs2 >= r2, 1, 'first');

    if isempty(m2) || m2 == m1
        freq_history(step+1,:)  = s / N;
        state_history(step+1,:) = s;
        continue;
    end

    % Execute switch
    s(m1) = s(m1) - 1;
    s(m2) = s(m2) + 1;

    freq_history(step+1,:)  = s / N;
    state_history(step+1,:) = s;
end
end