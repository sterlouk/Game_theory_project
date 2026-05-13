function [tx, ty] = ternary2cart(v)
% TERNARY2CART  Map a simplex frequency vector to 2-D Cartesian (ternary plot).
%
%   [tx, ty] = ternary2cart(v)
%
%   Convention (same triangle layout used by Lazaridis & Kehagias):
%     vertex 1 (All-M)  at top-left  (0, sqrt(3)/2)
%     vertex 2 (All-1)  at top-right (1, sqrt(3)/2)   <-- or bottom depending on style
%
%   We use the standard equilateral-triangle layout:
%     vertex 1 -> (0,       0        )   lower-left  = All-M
%     vertex 2 -> (1,       0        )   lower-right = All-1
%     vertex 3 -> (0.5,  sqrt(3)/2   )   top         = Grim
%
%   Input v: (n x 3) matrix (each row a frequency triple) or 3-vector.
%   Outputs: (n x 1) column vectors tx, ty.

if isvector(v), v = v(:)'; end

V = [0,  0;
     1,  0;
     0.5, sqrt(3)/2];          % 3x2 vertex positions

tx = v * V(:,1);   % (n x 3) * (3 x 1)
ty = v * V(:,2);
end
