function [test_acc_avg, test_acc_std, train_acc_avg, train_acc_std, diff_acc_avg, diff_acc_std, AEC, EC_std, ACS, DACS] = valid_kfold(features, labels, validation_runs, K, M_handle, is_random)

    num_samples = size(features, 1);
    group_size = round(num_samples / K);
    
    group_train_acc = zeros(1,K);
    train_acc = zeros(1,validation_runs);
    
    group_test_acc = zeros(1,K);
    test_acc = zeros(1,validation_runs);
    
    error_set = zeros(validation_runs, num_samples + 1);
    diff_acc = zeros(1,validation_runs);
    rnd_indices = 1:num_samples;
    
    for v = 1:validation_runs
        if is_random
            rnd_indices = randperm(num_samples);
        end
        
        rnd_features = features(rnd_indices,:,:);
        rnd_labels = labels(rnd_indices);
        
        num_error = 0;

        for g = 1:K
            
            if g < K
                testing_indices = group_size * (g - 1) + 1:group_size * (g);
            else
                testing_indices = group_size * (g - 1) + 1:num_samples;
            end
           
            testing_samples = size(testing_indices,2);
            training_samples = num_samples - testing_samples;
            
            training_set = rnd_features;
            training_set(testing_indices,:) = [];
            training_labels = rnd_labels;
            training_labels(testing_indices) = [];
            
            testing_set = rnd_features(testing_indices,:);
            testing_labels = rnd_labels(testing_indices);

            [group_train_pred, group_test_pred] = M_handle(training_set, training_labels, testing_set);

            group_train_error = abs(training_labels - group_train_pred);
            group_train_acc(g) = (training_samples - sum(group_train_error)) / training_samples;

            group_test_error = abs(testing_labels - group_test_pred);
            group_num_error = sum(group_test_error);
            group_test_acc(g) = (testing_samples - group_num_error) / testing_samples;
 
            error_indices = testing_indices(logical(group_test_error));
            error_set(v, num_error + 1:num_error + group_num_error) = rnd_indices(error_indices);
            num_error = num_error + group_num_error;
            
        end
    
        test_acc(v) = 100 * mean(group_test_acc);
        train_acc(v) = 100 * mean(group_train_acc);
        diff_acc(v) = train_acc(v) - test_acc(v);
        
    end
    
    test_acc_avg = mean(test_acc);
    test_acc_std = std(test_acc);
    train_acc_avg = mean(train_acc);
    train_acc_std = std(train_acc);
    diff_acc_avg = mean(diff_acc);
    diff_acc_std = std(diff_acc);
    
    [AEC, EC_std] = get_AEC(error_set);
    [ACS, DACS] = get_ACS(test_acc_avg, diff_acc_avg, labels);
    
end