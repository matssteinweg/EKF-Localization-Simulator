% This function performs one iteration of EKF localization.
% Inputs:
%           mu(t-1)                   3X1
%           sigma(t-1)                3X3
%           u                         3X1
%           z                         2Xn
%           association_ground_truth  1Xn
% Outputs:
%           mu(t)                     3X1
%           sigma(t)                  3X3
%           measurement_info          1Xn
function [mu, sigma, measurement_info] = ekf_localization(mu, sigma, u, z, association_ground_truth)

% set simulation mode
global BATCH_UPDATE % perform batch or sequential update
global DATA_ASSOCIATION % use association ground truth or perform ML data association

% import global variables
global Q
global landmark_ids % unique 
global t % global time

% number of measurements available
n_measurements = size(z, 2); 

% information on measurements: 0 correctly associated measurement | 1
% incorrectly associated measurement | 2 outlier
measurement_info = zeros(1, n_measurements);

% predict step
[mu_bar, sigma_bar] = predict(mu, sigma, u); 

% perform batch update
if strcmp(BATCH_UPDATE, 'On')
    
    % perform data association of all measurements
    [c, outlier, nu_bar, H_bar] = batch_associate(mu_bar, sigma_bar, z);
    % print number of outliers detected
    if sum(outlier)
        fprintf('warning, %d measurements were labeled as outliers, t=%d\n', sum(outlier), t);
    end
    
    % store information about measurements
    for i = 1 :n_measurements
        
        if strcmp(DATA_ASSOCIATION, 'On')
            associated_landmark = landmark_ids(c(i));
        else
            associated_landmark = association_ground_truth(i);
        end
        
        if association_ground_truth(i) ~= associated_landmark && outlier(i) == 0
            fprintf('warning, %d th measurement(of landmark %d) was incorrectly associated to landmark %d, t=%d\n', ...
                i, association_ground_truth(i), associated_landmark, t);
            measurement_info(i) = 1; % valid measurement incorrectly associated
        elseif outlier(i) == 1
            measurement_info(i) = 2; % outlier
        end
    end
    
    % extract valid measurements
    valid_indices = find(~outlier); 
    ix = [2*(valid_indices-1)+1;2*(valid_indices-1)+2];
    ix = ix(:); 
    nu_bar = nu_bar(ix);
    H_bar = H_bar(ix,:);
    n_valid_measurements = length(valid_indices);
    Q_bar = zeros(2*n_valid_measurements,2*n_valid_measurements);
    for i=1:n_valid_measurements
        ii= 2*i + (-1:0);
        Q_bar(ii,ii) = Q;
    end
    
    % perform update using only valid measurements
    [mu,sigma] = batch_update(mu_bar,sigma_bar,H_bar,Q_bar,nu_bar);   
    
% perform sequential update
else
    for i = 1:n_measurements
        
         % perform data association of single measurements
        [c, outlier, nu, S, H] = associate(mu_bar, sigma_bar, z(:,i));
        
        if strcmp(DATA_ASSOCIATION, 'On')
            associated_landmark = landmark_ids(c);
        else
            c = find(landmark_ids == association_ground_truth(i));
            associated_landmark = landmark_ids(c);
        end
        
        if association_ground_truth(i) ~= associated_landmark && outlier == 0
            fprintf('warning, %d th measurement(of landmark %d) was incorrectly associated to landmark %d, t=%d\n', ...
                i, association_ground_truth(i), associated_landmark, t);
            measurement_info(i) = 1; % valid measurement incorrectly associated
        elseif outlier == 1
            measurement_info(i) = 2; % outlier
            fprintf('%d th measurement was labeled as outlier, t=%d\n',i,t);
            continue
        end
   
        nu_bar = squeeze(nu(:,c));
        S_bar = squeeze(S(:,:,c));
        H_bar = squeeze(H(:,:,c));
        % update estimate using single measurement
        [mu_bar, sigma_bar] = update_(mu_bar, sigma_bar, H_bar, S_bar, nu_bar);   
    end
    
    % final estimate after last incorporated measurement
    mu = mu_bar;
    sigma = sigma_bar;
end
end
