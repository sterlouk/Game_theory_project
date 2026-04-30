function C = computeC(M, T, p)
% COMPUTEC  Compute the 5x5 ISC payoff matrix C.
%
%   C = computeC(M, T, p)
%
%   Strategies:
%     1 = All-M          : always play rho_M
%     2 = All-1          : always play rho_1
%     3 = Grim           : play rho_M; defect permanently after 1 sub-M
%     4 = Grim-Patient   : play rho_M; defect permanently after 2 consecutive sub-M
%     5 = Grim-Forgiver  : play rho_M; punish with rho_1 for 2 rounds then return
%
%   Parameters:
%     M  - number of OSC stages  (integer >= 3)
%     T  - number of ISC rounds  (integer >= 1)
%     p  - terminator payoff share in (0.5, 1]
%
%   OSC payoff to row player when row plays rho_i, col plays rho_j:
%     A(i,j) = i              if i == j
%     A(i,j) = (2i+1)*p       if i < j   (row terminates first)
%     A(i,j) = (2j+1)*(1-p)   if i > j   (col terminates first)
%
%   Key values (M >= 3, p in (0.5,1]):
%     A(M,M) = M
%     A(M,1) = 3*(1-p)   [row = rho_M, col terminates at stage 1]
%     A(1,M) = 3*p        [row terminates at stage 1 while col would go to M]
%     A(1,1) = 1

% --- OSC payoff helper -------------------------------------------------
A = @(i,j) (i==j)*i + (i<j)*(2*i+1)*p + (i>j)*(2*j+1)*(1-p);

AMM = A(M,M);   % = M
AM1 = A(M,1);   % = 3*(1-p)
A1M = A(1,M);   % = 3*p
A11 = A(1,1);   % = 1

% GrimForgiver against All-1: plays rho_M in rounds 1, 4, 7, ...
%   => ceil(T/3) rounds of rho_M, T - ceil(T/3) rounds of rho_1
nM_GF = ceil(T/3);

C = zeros(5,5);

% -----------------------------------------------------------------------
% Row 1: All-M  (always rho_M, never sub-M => never triggers anyone)
% -----------------------------------------------------------------------
C(1,1) = T * AMM;           % vs All-M   : both rho_M every round
C(1,2) = T * AM1;           % vs All-1   : col terminates at 1 every round
C(1,3) = T * AMM;           % vs Grim    : Grim never triggered
C(1,4) = T * AMM;           % vs GrimP   : GrimP never triggered
C(1,5) = T * AMM;           % vs GrimF   : GrimF never triggered

% -----------------------------------------------------------------------
% Row 2: All-1  (always rho_1, triggers every opponent's Grim variant)
% -----------------------------------------------------------------------
C(2,1) = T * A1M;           % vs All-M   : row terminates at 1 every round

C(2,2) = T * A11;           % vs All-1   : both rho_1 every round

% vs Grim: Grim plays rho_M in round 1, then rho_1 permanently
%   Round 1  : All-1 vs rho_M  => A(1,M)
%   Rounds 2..T: All-1 vs rho_1 => A(1,1)
C(2,3) = A1M + (T-1)*A11;

% vs Grim-Patient: GrimP plays rho_M for 2 rounds (needs 2 consecutive), then rho_1
%   Rounds 1,2: All-1 vs rho_M  => A(1,M) each
%   Rounds 3..T: All-1 vs rho_1 => A(1,1)
r24 = min(2,T);
C(2,4) = r24*A1M + max(T-2,0)*A11;

% vs Grim-Forgiver: GrimF plays rho_M in rounds 1,4,7,...
%   nM_GF rounds of rho_M, rest rho_1
C(2,5) = nM_GF*A1M + (T - nM_GF)*A11;

% -----------------------------------------------------------------------
% Row 3: Grim  (triggers permanently after seeing one sub-M)
%   Against All-M / Grim / GrimP / GrimF: opponent always plays rho_M
%   => Grim never triggers => both play rho_M all T rounds
% -----------------------------------------------------------------------
C(3,1) = T * AMM;
C(3,3) = T * AMM;
C(3,4) = T * AMM;
C(3,5) = T * AMM;

% vs All-1: Grim plays rho_M in round 1 (sees rho_1 => triggers), rho_1 for rounds 2..T
%   Round 1  : rho_M vs rho_1  => A(M,1)
%   Rounds 2..T: rho_1 vs rho_1 => A(1,1)
C(3,2) = AM1 + (T-1)*A11;

% -----------------------------------------------------------------------
% Row 4: Grim-Patient  (triggers after 2 consecutive sub-M observations)
%   Against All-M / Grim / GrimP / GrimF: opponent plays rho_M always
%   => count never reaches 2 => GrimP never triggers
% -----------------------------------------------------------------------
C(4,1) = T * AMM;
C(4,3) = T * AMM;
C(4,4) = T * AMM;
C(4,5) = T * AMM;

% vs All-1: GrimP plays rho_M rounds 1,2 (count hits 2 at end of round 2), then rho_1
%   Rounds 1,2: rho_M vs rho_1 => A(M,1)
%   Rounds 3..T: rho_1 vs rho_1 => A(1,1)
r42 = min(2,T);
C(4,2) = r42*AM1 + max(T-2,0)*A11;

% -----------------------------------------------------------------------
% Row 5: Grim-Forgiver  (punish for 2 rounds then forgive, repeat)
%   Against All-M / Grim / GrimP / GrimF: opponent plays rho_M always
%   => GrimF never triggers
% -----------------------------------------------------------------------
C(5,1) = T * AMM;
C(5,3) = T * AMM;
C(5,4) = T * AMM;
C(5,5) = T * AMM;

% vs All-1: GrimF cycles rho_M(1), rho_1(2), rho_1(3), rho_M(4), ...
%   Plays rho_M in rounds 1,4,7,... => ceil(T/3) times
%   nM_GF rounds of rho_M vs rho_1 => A(M,1) each
%   Remaining rounds: rho_1 vs rho_1 => A(1,1)
C(5,2) = nM_GF*AM1 + (T - nM_GF)*A11;

end