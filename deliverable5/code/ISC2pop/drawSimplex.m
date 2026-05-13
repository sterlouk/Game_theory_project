function drawSimplex(labels, col)
% DRAWSIMPLEX  Draw an equilateral-triangle simplex with labelled vertices.
%
%   drawSimplex()
%   drawSimplex(labels)          labels = {'All-M','All-1','Grim'}
%   drawSimplex(labels, col)     col = edge colour (default [.3 .3 .3])
%
%   Vertices (same convention as ternary2cart):
%     v1 (lower-left)  = All-M
%     v2 (lower-right) = All-1
%     v3 (top-centre)  = Grim

if nargin < 1 || isempty(labels)
    labels = {'All-$M$', 'All-$1$', 'Grim'};
end
if nargin < 2, col = [0.3 0.3 0.3]; end

V = [0,         0;
     1,         0;
     0.5, sqrt(3)/2];

% Fill
fill(V([1 2 3 1],1), V([1 2 3 1],2), [0.97 0.97 0.97], ...
     'EdgeColor', col, 'LineWidth', 1.6);
hold on;

% Grid lines at 1/3 and 2/3
for frac = [1/3, 2/3]
    % Lines parallel to each side
    for k = 1:3
        k2 = mod(k,3)+1;
        k3 = mod(k+1,3)+1;
        p1 = frac*V(k,:) + (1-frac)*V(k2,:);
        p2 = frac*V(k,:) + (1-frac)*V(k3,:);
        plot([p1(1) p2(1)],[p1(2) p2(2)], '-', ...
             'Color',[0.8 0.8 0.8],'LineWidth',0.5);
    end
end

% Vertex dots
plot(V(:,1), V(:,2), 'k.', 'MarkerSize', 14);

% Labels
offset = 0.08;
align  = {'right','left','center'};
valign = {'top','top','bottom'};
nudge  = [-offset, offset, 0; ...
          -0.03, 0.03, 0];
for k = 1:3
    text(V(k,1)+nudge(1,k), V(k,2)+nudge(2,k), labels{k}, ...
         'FontSize',11,'FontWeight','bold','Interpreter','latex', ...
         'HorizontalAlignment', align{k}, ...
         'VerticalAlignment',   valign{k});
end

axis equal; axis off;
end
