% This function is the implementation of the jacobian measurement model
% required for the update of the covariance function after incorporating
% the measurements
% Inputs:
%           x(t)        3X1
%           j           1X1 which landmark (map column)
%           z_j         2X1
% Outputs:  
%           H           2X3
function H = jacobian_measurement_model(x, j, z_j)

global map % map including the coordinates of all landmarks | shape 2Xn for n landmarks

    h_11 = (x(1) - map(1, j)) / z_j(1);
    h_21 =  - (x(2) - map(2, j)) / z_j(1)^2;
    h_12 = (x(2) - map(2, j)) / z_j(1);
    h_22 = (x(1) - map(1, j)) / z_j(1)^2;
    h_13 = 0;
    h_23 = -1;

    H = [h_11, h_12, h_13;
         h_21, h_22, h_23];
end
