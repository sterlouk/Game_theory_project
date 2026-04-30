function [P, states, stateMap] = buildMarkovP5(C, N)
% BUILDMARKOVP5  Build the Markov transition matrix for the 5-strategy
%                ISC evolutionary game under Pairwise Proportional Imitation.
%
%   [P, states, stateMap] = buildMarkovP5(C, N)
%
%   Arguments:
%     C        - 5x5 ISC payoff matrix
%     N        - number of players (positive integer; recommended N <= 15)
%
%   Returns:
%     P        - (nS x nS) sparse transition matrix  (P(i,j) = Prob(i -> j))
%     states   - (nS x 5) matrix; row i is the state vector s
%     stateMap - containers.Map from state string to row index
%
%   State:   s = (s1,s2,s3,s4,s5),  sum(s) = N,  s_k >= 0.
%   Payoff to one m-user when the full population is s:
%     q_m(s) = (s_m - 1)*C(m,m) + sum_{n != m} s_n * C(m,n)
%
%   PPI revision protocol:
%     A selected m1-user switches to m2 with probability
%       rho_{m1,m2} = x_{m2} * [q_{m2} - q_{m1}]+ / sum_n x_n*[q_n-q_{m1}]+
%     where x_k = s_k / N.
%     The transition  s -> s - e_{m1} + e_{m2}  has probability
%       (s_{m1}/N) * rho_{m1,m2}.

K = size(C, 1);          % = 5
states   = enumStates(N, K);
nS       = size(states, 1);

% Build a map  state_string -> index  for fast lookup
keys = cell(nS, 1);
for i = 1:nS
    keys{i} = mat2str(states(i,:));
end
stateMap = containers.Map(keys, num2cell(1:nS));

% Pre-allocate sparse triplets
iIdx = zeros(nS*K*(K-1), 1);
jIdx = zeros(nS*K*(K-1), 1);
vVal = zeros(nS*K*(K-1), 1);
ptr  = 0;

% Self-transition accumulator per state
selfProb = ones(nS, 1);

for idx = 1:nS
    s = states(idx, :);   % 1 x K current state

    % Per-player payoffs for each strategy
    q = zeros(1, K);
    for m = 1:K
        if s(m) == 0
            q(m) = -Inf;  % undefined payoff; won't be selected
            continue;
        end
        q(m) = (s(m)-1)*C(m,m) + sum(s .* C(m,:)) - s(m)*C(m,m);
        % = sum_{n} s_n * C(m,n) - C(m,m)   [subtract the self-play once
        %   to go from "against all N-1 others"]
        % Equivalently: q(m) = sum_{n != m} s_n * C(m,n) + (s(m)-1)*C(m,m)
    end

    x = s / N;   % frequency vector

    % Iterate over all (m1, m2) pairs with s(m1) > 0
    for m1 = 1:K
        if s(m1) == 0, continue; end

        % Surplus of each strategy over m1
        surplus = max(q - q(m1), 0);   % 1 x K, entry m1 is 0
        surplus(m1) = 0;

        denom = sum(x .* surplus);

        if denom < 1e-14
            continue;   % no beneficial switch possible
        end

        for m2 = 1:K
            if m2 == m1, continue; end
            if s(m2) == 0 && surplus(m2) == 0, continue; end  % no target

            rho = x(m2) * surplus(m2) / denom;
            if rho < 1e-14, continue; end

            % Transition probability s -> s'
            trans_prob = (s(m1)/N) * rho;

            % Target state
            s_new = s;
            s_new(m1) = s_new(m1) - 1;
            s_new(m2) = s_new(m2) + 1;

            key_new = mat2str(s_new);
            if ~isKey(stateMap, key_new), continue; end
            jj = stateMap(key_new);

            ptr = ptr + 1;
            iIdx(ptr) = idx;
            jIdx(ptr) = jj;
            vVal(ptr) = trans_prob;
            selfProb(idx) = selfProb(idx) - trans_prob;
        end
    end
end

% Trim pre-allocated arrays
iIdx = iIdx(1:ptr);
jIdx = jIdx(1:ptr);
vVal = vVal(1:ptr);

% Add self-transition entries
selfProb = max(selfProb, 0);   % numerical safety
iSelf = (1:nS)';
jSelf = (1:nS)';
vSelf = selfProb;

P = sparse([iIdx; iSelf], [jIdx; jSelf], [vVal; vSelf], nS, nS);

% Row-normalise (safety: rows should already sum to 1)
rowsums = full(sum(P, 2));
rowsums(rowsums < 1e-14) = 1;
P = P ./ rowsums;
end