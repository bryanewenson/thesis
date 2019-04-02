function [F, D] = fs_rand(num_useful_features, D, num_trials, num_select)

    f_selections = zeros(num_trials, num_select);
    d_means = zeros(1,num_trials);

    for t = 1:num_trials
        f_selections(t,:) = randsample(num_useful_features, num_select);
        d_means(t) = mean(D(f_selections(t,:)));
    end

    F = f_selections;
    D = d_means;    
    
end