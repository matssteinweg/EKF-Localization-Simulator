% This function performs the maximum likelihood association and outlier detection given a single measurement.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z_i(t)              2X1
% Outputs: 
%           c(t)                1X1
%           outlier             1X1
%           nu^i(t)             2XN
%           S^i(t)              2X2XN
%           H^i(t)              2X3XN
function [c, outlier, nu, S, H] = associate(mu_bar, sigma_bar, z_i)

    global Q
    global lambda_m
    global map

    n_states = size(mu_bar, 1);
    n_measures = size(z_i, 1);
    n_landmarks = size(map, 2);

    H = zeros(n_measures, n_states, n_landmarks); % jacobian measurement model
    S = zeros(n_measures, n_measures, n_landmarks); % error covariance matrix
    nu = zeros(n_measures, n_landmarks); % innovation
    D_m = zeros(1, n_landmarks); % mahalanobis distance
    likelihoods = zeros(1, n_landmarks);

    for j = 1:n_landmarks

        % predict measurement for current landmark
        z_j = measurement_model(mu_bar, j);
        % get jacobian measurement model
        H(:,:,j) = jacobian_measurement_model(mu_bar, j, z_j);
        % update covariance matrix
        S(:,:,j) = H(:,:,j) * sigma_bar * H(:,:,j)' + Q;
        % compute innovation
        nu(:, j) = z_i - z_j;
        nu(2, j) = mod(nu(2,j)+pi,2*pi)-pi;
        % compute mahalanobis distance
        D_m(j) = nu(:,j)' / S(:,:,j) * nu(:,j);
        % compute likelihood
        likelihoods(j) = det(2*pi*S(:,:,j)).^(-1/2) * exp(-1/2*D_m(j));

    end

    % get index of most likely landmark
    [~, c] = max(likelihoods(:));

    % check if mahalanobis distance greater than threshold for outlier
    % detection
    if D_m(c) >= lambda_m
        outlier = 1;
    else
        outlier = 0;
    end
end