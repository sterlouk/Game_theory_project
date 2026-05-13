function C = computeC(M, T, p)
% COMPUTEC  ISC payoff matrix for All-M / All-1 / Grim (original paper).
%
%   C = computeC(M, T, p)
%
%   C(i,j) = payoff to strategy i when playing against strategy j over T rounds.
%
%   Strategies:
%     1 = All-M  : always play rho_M
%     2 = All-1  : always play rho_1
%     3 = Grim   : play rho_M; if opponent ever plays rho_m with m<M,
%                  switch permanently to rho_1
%
%   In the TWO-POPULATION setting the bimatrix game is (C, C^T):
%     Population 1 (row player)  gets C(i,j)
%     Population 2 (col player)  gets C(j,i)  [= C^T(i,j)]
%
%   OSC payoff A(i,j) to the row player:
%     A(i,i) = i
%     A(i,j) = (2i+1)*p      if i < j   (row terminates first)
%     A(i,j) = (2j+1)*(1-p)  if i > j   (col terminates first)

AMM = M;            % A(M,M)
A11 = 1;            % A(1,1)
AM1 = 3*(1-p);      % A(M,1): col terminates at stage 1 < M
A1M = 3*p;          % A(1,M): row terminates at stage 1 < M

C = [ T*AMM,          T*AM1,           T*AMM;
      T*A1M,          T*A11,           A1M + (T-1)*A11;
      T*AMM,          AM1 + (T-1)*A11, T*AMM ];
%
% Explanation of non-trivial entries:
%   C(2,3): All-1 vs Grim.  Round 1: Grim plays rho_M, row plays rho_1 => A(1,M)=3p.
%           Grim triggers. Rounds 2..T: both rho_1 => A(1,1)=1.
%           Total = 3p + (T-1).
%   C(3,2): Grim vs All-1.  Round 1: Grim plays rho_M, sees rho_1 => A(M,1)=3(1-p).
%           Grim triggers. Rounds 2..T: both rho_1 => 1.
%           Total = 3(1-p) + (T-1).
%   All other Grim entries: never triggered by rho_M opponents => TM every round.
end
