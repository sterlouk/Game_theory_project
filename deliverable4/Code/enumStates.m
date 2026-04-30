function S = enumStates(N, K)
% ENUMSTATES  All non-negative integer vectors of length K summing to N.
%
%   S = enumStates(N, K)
%
%   Returns an  (nStates x K)  matrix where every row is an admissible
%   population state  s = (s_1, ..., s_K)  with s_k >= 0 and sum(s) = N.
%   The number of rows is  nchoosek(N+K-1, K-1).
%
%   Arguments:
%     N  - total number of players  (positive integer)
%     K  - number of strategies     (positive integer, default 5)

if nargin < 2
    K = 5;
end

S = enumRec(N, K);
end

% -------------------------------------------------------------------
function S = enumRec(N, K)
% Recursive helper: enumerate non-negative vectors of length K summing to N.
if K == 1
    S = N;
    return;
end
S = zeros(0, K);
for s1 = 0:N
    sub = enumRec(N - s1, K - 1);
    n   = size(sub, 1);
    S   = [S; s1*ones(n,1), sub];   %#ok<AGROW>
end
end