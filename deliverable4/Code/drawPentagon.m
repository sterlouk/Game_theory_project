function drawPentagon()
% DRAWPENTAGON  Draw the 5-strategy simplex as a regular pentagon.
%
% Strategy order (clockwise, starting at top):
%   1 = All-M, 2 = All-1, 3 = Grim, 4 = GrimP, 5 = GrimF

angles = pi/2 - (0:4) * 2*pi/5;
vx = cos(angles);
vy = sin(angles);

% Background fill
fill(vx, vy, [0.95 0.95 0.95], 'EdgeColor', 'k', 'LineWidth', 1.2);
hold on;

% Diagonals
for i = 1:5
	for j = i+1:5
		plot([vx(i) vx(j)], [vy(i) vy(j)], 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
	end
end

% Vertices
plot(vx, vy, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 7);

% Labels
labels = {'All-M', 'All-1', 'Grim', 'GrimP', 'GrimF'};
for i = 1:5
	ha = 'center'; va = 'middle';
	if vx(i) > 0.2, ha = 'left'; end
	if vx(i) < -0.2, ha = 'right'; end
	if vy(i) > 0.2, va = 'bottom'; end
	if vy(i) < -0.2, va = 'top'; end
	text(vx(i), vy(i), labels{i}, 'HorizontalAlignment', ha, 'VerticalAlignment', va);
end

% Cooperative face outline (All-M, Grim, GrimP, GrimF)
coop_idx = [1 3 4 5 1];
plot(vx(coop_idx), vy(coop_idx), '--', 'Color', [0.2 0.4 0.8], 'LineWidth', 1.0);

axis equal;
axis off;
end
