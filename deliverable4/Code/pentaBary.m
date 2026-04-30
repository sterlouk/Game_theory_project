function [X, Y] = pentaBary(x)
% PENTABARY  Map 5-strategy frequency vectors to 2-D pentagon coordinates.
%
%   [X, Y] = pentaBary(x)
%
%   Each strategy corresponds to a vertex of a regular pentagon.
%   Vertex k is placed at angle  theta_k = pi/2 - 2*pi*(k-1)/5  so that
%   strategy 1 is at the top and the others go clockwise.
%
%   The 2-D representative of a frequency vector x = (x1,...,x5) is the
%   barycentric combination  (X,Y) = sum_k  x_k * v_k  where v_k is the
%   2-D position of the k-th vertex.
%
%   Arguments:
%     x  - (n x 5) matrix  OR  5-element vector
%          Each row is a frequency vector (need not sum to 1 exactly).
%
%   Returns:
%     X, Y  - (n x 1) column vectors of 2-D coordinates.

if isvector(x)
    x = x(:)';          % ensure row vector, then treat as 1-row matrix
end

% Vertex angles: top = pi/2, going clockwise
angles = pi/2 - (0:4) * 2*pi/5;   % 1x5

Vx = cos(angles);   % 1x5
Vy = sin(angles);   % 1x5

X = x * Vx';        % (n x 5) * (5 x 1) = (n x 1)
Y = x * Vy';
end