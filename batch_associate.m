% This function performs the maximum likelihood association and outlier detection.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z(t)                2Xn
% Outputs: 
%           c(t)                1Xn
%           outlier             1Xn
%           nu_bar(t)           2nX1
%           H_bar(t)            2nX3
function [c, outlier, nu_bar, H_bar] = batch_associate(mu_bar, sigma_bar, z)

    n_measurements = size(z, 2); % number of measurements in batch

    c = zeros(1, n_measurements); % associated landmark index
    outlier = zeros(1, n_measurements); % boolean | 1 measurement detected as outlier, 0 valid measurement
    nu_bar = zeros(2*n_measurements, 1); % innovation | difference between measurement and predicted measurement of associated landmark
    H_bar = zeros(2*n_measurements, 3); % jacobian measurement model

    for i = 1:n_measurements

        % perform ML association for single measurement
        [c_i, outlier_i, nu_i, ~, H_i] = associate(mu_bar, sigma_bar, z(:,i));
        % index of most likely landmark
        c(i) = c_i;
        % outlier detected?
        outlier(i) = outlier_i;
        % likelihood and jacobian
        nu_bar((i-1)*2+1:i*2) = nu_i(:,c_i);
        H_bar((i-1)*2+1:i*2,:) = H_i(:,:,c_i);

    end
end