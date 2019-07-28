% This function calculates the odometry information
% Inputs:
%           e_L(t):         1X1
%           e_R(t):         1X1
%           delta_t:        1X1
%           mu(t-1):        3X1
% Outputs:
%           u(t):           3X1
function u = calculate_odometry(e_R,e_L,delta_t,mu)
if ~delta_t
    u = [0;0;0];
    return;
end

% odometry parameters
E_T = 2048; % encoder ticks per wheel evolution
B= 0.35; % distance between contact points of wheels in m
R_L = 0.1; % radius of the left wheel in m
R_R = 0.1; % radius of the right wheel in m

omega_R_t = 2 * pi * e_R / (E_T * delta_t);
omega_L_t = 2 * pi * e_L / (E_T * delta_t);
omega_t = (omega_R_t * R_R - omega_L_t * R_L) / B;
velocity_t = (omega_R_t * R_R + omega_L_t * R_L) / 2;
u = [velocity_t * delta_t * cos(mu(3));
     velocity_t * delta_t * sin(mu(3));
     omega_t * delta_t];

end