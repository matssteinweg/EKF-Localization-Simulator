% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           x(t)                           3X1
%           j                              1X1
% Outputs:  
%           h                              2X1
function z_j = measurement_model(x, j)

global map % map including the coordinates of all landmarks | shape 2Xn for n landmarks

% get distance to landmark j
r = norm(map(:, j) - x(1:2));
% get angle to landmark j
phi = atan2((map(2, j) - x(2)), map(1, j) - x(1)) - x(3);
phi_shift = mod(phi+pi,2*pi) - pi;

% expected measurement of landmark j
z_j = [r; phi_shift];

end