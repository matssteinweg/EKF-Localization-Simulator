% This function performs the prediction step.
% Inputs:
%           mu(t-1)           3X1   
%           sigma(t-1)        3X3
%           u(t)              3X1
% Outputs:   
%           mu_bar(t)         3X1
%           sigma_bar(t)      3X3
function [mu_bar, sigma_bar] = predict(mu, sigma, u)

    global R % covariance matrix of motion model | shape 3X3

    % update mean 
    mu_bar = mu + u;
    % jacobian motion model
    G_t = [1, 0, -u(2);
           0, 1,  u(1);
           0, 0, 1];
    % update covariance matrix
    sigma_bar = G_t * sigma * G_t' + R;
    
end