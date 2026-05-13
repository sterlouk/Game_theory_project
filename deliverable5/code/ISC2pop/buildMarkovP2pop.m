function [P, states1, states2] = buildMarkovP2pop(C, N1, N2)
% BUILDMARKOVP2POP  Exact Markov transition matrix for the two-population ISC.
%
%   [P, states1, states2] = buildMarkovP2pop(C, N1, N2)
%
%   TWO-POPULATION game: every pop-1 player vs every pop-2 player.
%   Per-player payoffs (no within-population interaction):
%     q_m^(1)(s,t) = sum_n t_n * C(m,n)
%     q_n^(2)(s,t) = sum_m s_m * C(m,n)  = (C^T * s)_n
%
%   State: (s, t) where s=(s1,s2,s3) sums to N1, t=(t1,t2,t3) sums to N2.
%   Total states: nchoosek(N1+2,2) * nchoosek(N2+2,2).
%   At each step one population is chosen (50/50) and one player is updated.
%
%   Arguments:
%     C   - 3x3 payoff matrix
%     N1  - pop-1 size  (recommended <= 10 for tractability)
%     N2  - pop-2 size
%
%   Returns:
%     P       - sparse transition matrix (nS x nS)
%     states1 - (n1 x 3) all states for pop 1
%     states2 - (n2 x 3) all states for pop 2

% --- enumerate states ---------------------------------------------------
states1 = enumStates3(N1);   % n1 x 3
states2 = enumStates3(N2);   % n2 x 3
n1 = size(states1,1);
n2 = size(states2,1);
nS = n1*n2;                  % total states

% build index maps
map1 = buildMap(states1, N1);
map2 = buildMap(states2, N2);

% combined linear index: (i1-1)*n2 + i2
linIdx = @(i1,i2) (i1-1)*n2 + i2;

% --- build sparse P -----------------------------------------------------
iIdx = zeros(nS*20, 1);
jIdx = zeros(nS*20, 1);
vVal = zeros(nS*20, 1);
ptr  = 0;

selfProb = ones(nS,1);

for i1 = 1:n1
    s = states1(i1,:);     % pop-1 state
    for i2 = 1:n2
        t = states2(i2,:); % pop-2 state
        idx = linIdx(i1,i2);

        % --- cross-population payoffs ---
        q1 = (C  * t')';   % 1x3  pop-1 payoffs: sum_n t_n*C(m,n)
        q2 = (C' * s')';   % 1x3  pop-2 payoffs: sum_m s_m*C(m,n)

        % --- update pop 1 (probability 1/2) ---
        x = s/N1;
        for m1 = 1:3
            if s(m1)==0, continue; end
            surplus = max(q1 - q1(m1), 0);
            surplus(m1) = 0;
            denom = sum(x .* surplus);
            if denom < 1e-14, continue; end
            for m2 = 1:3
                if m2==m1 || s(m2)==0 && surplus(m2)==0, continue; end
                rho = x(m2)*surplus(m2)/denom;
                if rho < 1e-14, continue; end
                tp = 0.5 * (s(m1)/N1) * rho;  % 1/2 for choosing pop1
                s_new = s; s_new(m1)=s_new(m1)-1; s_new(m2)=s_new(m2)+1;
                key = num2str(s_new);
                if ~isKey(map1,key), continue; end
                j1 = map1(key);
                j  = linIdx(j1,i2);
                ptr=ptr+1; iIdx(ptr)=idx; jIdx(ptr)=j; vVal(ptr)=tp;
                selfProb(idx) = selfProb(idx) - tp;
            end
        end

        % --- update pop 2 (probability 1/2) ---
        y = t/N2;
        for n1_ = 1:3
            if t(n1_)==0, continue; end
            surplus2 = max(q2 - q2(n1_), 0);
            surplus2(n1_) = 0;
            denom2 = sum(y .* surplus2);
            if denom2 < 1e-14, continue; end
            for n2_ = 1:3
                if n2_==n1_ || t(n2_)==0 && surplus2(n2_)==0, continue; end
                rho2 = y(n2_)*surplus2(n2_)/denom2;
                if rho2 < 1e-14, continue; end
                tp2 = 0.5 * (t(n1_)/N2) * rho2;
                t_new = t; t_new(n1_)=t_new(n1_)-1; t_new(n2_)=t_new(n2_)+1;
                key2 = num2str(t_new);
                if ~isKey(map2,key2), continue; end
                j2 = map2(key2);
                j  = linIdx(i1,j2);
                ptr=ptr+1; iIdx(ptr)=idx; jIdx(ptr)=j; vVal(ptr)=tp2;
                selfProb(idx) = selfProb(idx) - tp2;
            end
        end
    end
end

% assemble
iIdx=iIdx(1:ptr); jIdx=jIdx(1:ptr); vVal=vVal(1:ptr);
selfProb = max(selfProb,0);
P = sparse([iIdx;(1:nS)'],[jIdx;(1:nS)'],[vVal;selfProb],nS,nS);
rs = full(sum(P,2)); rs(rs<1e-14)=1;
P  = P ./ rs;
end

% -----------------------------------------------------------------------
function S = enumStates3(N)
% All (s1,s2,s3) with si>=0, sum=N
S = [];
for a = 0:N
    for b = 0:N-a
        S(end+1,:) = [a, b, N-a-b]; %#ok<AGROW>
    end
end
end

function m = buildMap(states, ~)
n = size(states,1);
keys = cell(n,1);
for i=1:n, keys{i} = num2str(states(i,:)); end
m = containers.Map(keys, num2cell(1:n));
end
