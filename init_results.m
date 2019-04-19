function results = init_results(plot_type_keyval, n_experiments, n_trials, n_select)

    max = n_experiments;

    results(max).EC_avg = zeros(1,n_trials);
    results(max).test_acc = zeros(1,n_trials);
    
    results(max).train_acc = zeros(1,n_trials);
    results(max).CV = zeros(1,n_trials);
    results(max).DCV = zeros(1,n_trials);
    
    switch plot_type_keyval
        case 1
            results(max).F_idx = zeros(1,n_select);
            results(max).D_mean = zeros(1,n_trials);
        
        case 2
            results(max).ssp = 0;            
        
        case 3
            
    end
end