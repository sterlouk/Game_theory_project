function PStateTransitionGraph2pop(C, N1, N2, titleStr)
% PSTATETRANSITIONGRAPH2POP  Plot the two-population Markov state transition graph.
%
%   PStateTransitionGraph2pop(C, N1, N2, titleStr)
%
%   Because the full state space (s,t) is (n1*n2) dimensional, we project
%   each state onto 2-D using pop-1 (s1,s2) and pop-2 (t1,t2) coordinates
%   and draw arrows for non-zero transitions.
%   Two subplots: left = pop-1 simplex projection, right = pop-2 simplex.
%
%   Arguments:
%     C        - 3x3 payoff matrix
%     N1, N2   - population sizes  (keep <= 6 for legibility)
%     titleStr - figure title

if nargin < 4, titleStr = 'State Transition Graph (2-pop)'; end

[P, states1, states2] = buildMarkovP2pop(C, N1, N2);
n1 = size(states1,1);
n2 = size(states2,1);
nS = n1*n2;
linIdx = @(i1,i2) (i1-1)*n2 + i2;

% --- Identify absorbing states -----------------------------------------
absIdx = find(abs(diag(P)-1) < 1e-8);

% 2-D ternary coordinates for each population state
[tx1,ty1] = ternary2cart(states1/N1);
[tx2,ty2] = ternary2cart(states2/N2);

figure('Units','centimeters','Position',[2 2 28 13]);
labs = {'All-$M$','All-$1$','Grim'};

for panel = 1:2
    subplot(1,2,panel); hold on;
    drawSimplex(labs);
    title([titleStr, ' — Pop ', num2str(panel)], ...
          'FontSize',10,'Interpreter','latex');
end

% --- Draw transitions ---------------------------------------------------
thresh = 1e-3;
[Is,Js,Vs] = find(P);

for k = 1:numel(Is)
    if Is(k)==Js(k) || Vs(k) < thresh, continue; end
    si = mod(Is(k)-1, n2) + 1;   % state-2 index of source
    % Recover (i1,i2) from linear index
    i1_from = ceil(Is(k)/n2);
    i2_from = mod(Is(k)-1,n2)+1;
    i1_to   = ceil(Js(k)/n2);
    i2_to   = mod(Js(k)-1,n2)+1;

    lw = max(0.3, Vs(k)*4);
    col = [0.2 0.4 0.9];

    % Pop-1 panel: arrow if pop-1 state changes
    if i1_from ~= i1_to
        subplot(1,2,1);
        drawArrow2D([tx1(i1_from) ty1(i1_from)],[tx1(i1_to) ty1(i1_to)], lw, col);
    end
    % Pop-2 panel: arrow if pop-2 state changes
    if i2_from ~= i2_to
        subplot(1,2,2);
        drawArrow2D([tx2(i2_from) ty2(i2_from)],[tx2(i2_to) ty2(i2_to)], lw, col);
    end
end

% --- Mark absorbing states -----------------------------------------------
for a = absIdx'
    i1 = ceil(a/n2);
    i2 = mod(a-1,n2)+1;
    subplot(1,2,1); plot(tx1(i1),ty1(i1),'bo','MarkerFaceColor','b','MarkerSize',8);
    subplot(1,2,2); plot(tx2(i2),ty2(i2),'bo','MarkerFaceColor','b','MarkerSize',8);
end

% All transient states (grey dots)
allIdx = 1:nS;
transIdx = setdiff(allIdx, absIdx);
for a = transIdx
    i1 = ceil(a/n2);
    i2 = mod(a-1,n2)+1;
    subplot(1,2,1); plot(tx1(i1),ty1(i1),'r.','MarkerSize',8);
    subplot(1,2,2); plot(tx2(i2),ty2(i2),'r.','MarkerSize',8);
end

drawnow;
end

% -----------------------------------------------------------------------
function drawArrow2D(from, to, lw, col)
dx = to(1)-from(1); dy = to(2)-from(2);
if norm([dx dy]) < 1e-6, return; end
quiver(from(1),from(2),dx*0.85,dy*0.85,0, ...
       'Color',col,'LineWidth',lw,'MaxHeadSize',0.5,'AutoScale','off');
end
