function [F_idx, D_mean] = fs_rand(D, n_select, n_trials)
    
    n_features = size(D,1);
    
    F_idx = zeros(n_trials, n_select);
    D_mean = zeros(n_trials,1);
    
    for i = 1:n_trials
        F_idx(i,:) = randi(n_features,[1,n_select]);
        D_mean(i) = mean(D(F_idx(i,:)));
    end
    
end