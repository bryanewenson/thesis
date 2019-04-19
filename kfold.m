function [EC_avg, avg_test_acc, avg_train_acc, CV, DCV] = kfold(features, labels, validation_runs, K, M_handle)

    num_samples = size(features, 1)
    group_size = round(num_samples / K);
    
    group_train_acc = zeros(1,K);
    train_acc = zeros(1,validation_runs);
    
    group_test_acc = zeros(1,K);
    test_acc = zeros(1,validation_runs);
    
    error_set = zeros(validation_runs, num_samples + 1);
    
    for v = 1:validation_runs
        rnd_indices = randperm(num_samples);
        rnd_features = features(rnd_indices,:);
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

            if nargin == 6
                [group_train_pred, group_test_pred] = M_handle(training_set, training_labels, testing_set, M_param);
            else
                [group_train_pred, group_test_pred] = M_handle(training_set, training_labels, testing_set);
            end
                
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
        diff_acc = train_acc - test_acc;
        
    end
    
    avg_test_acc = mean(test_acc);
    avg_train_acc = mean(train_acc);
    
    EC_avg = error_consistency(error_set);
    CV = 0;
    DCV = 0;
    %[CV, DCV] = classifier_value(test_acc, diff_acc, labels);
    
end