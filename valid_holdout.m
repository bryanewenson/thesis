function [test_acc_avg, test_acc_std, train_acc_avg, train_acc_std, diff_acc_avg, diff_acc_std, AEC, EC_std, RS, RSQ] = valid_holdout(features, labels, validation_runs, holdout_ratio, M_handle, is_random)

    num_samples = size(features, 1);
    
    train_acc = zeros(1,validation_runs);
    train_samples = round(num_samples * holdout_ratio);
    
    test_acc = zeros(1,validation_runs);
    test_samples = num_samples - train_samples;
    
    error_set = zeros(validation_runs, test_samples + 1);
    diff_acc = zeros(1,validation_runs);
    rnd_indices = 1:num_samples;
    
    for v = 1:validation_runs        
        if is_random
            rnd_indices = randperm(num_samples);
        end

        training_indices = rnd_indices(1:train_samples);
        training_set = features(training_indices,:);
        training_labels = labels(training_indices);
        
        testing_indices = rnd_indices((train_samples + 1):num_samples);
        testing_set = features(testing_indices,:);
        testing_labels = labels(testing_indices);

        [training_pred, testing_pred] = M_handle(training_set, training_labels, testing_set);
        
        training_error = abs(training_labels - training_pred);
        train_acc(v) = 100 * (train_samples - sum(training_error)) / train_samples;
        
        testing_error = abs(testing_labels - testing_pred);
        test_acc(v) = 100 * (test_samples - sum(testing_error)) / test_samples;
        
        diff_acc(v) = train_acc(v) - test_acc(v);
    
        error_indices = testing_indices(logical(testing_error));
        num_error = size(error_indices,2);
        error_set(v, 1:num_error) = rnd_indices(error_indices);

    end
    
    test_acc_avg = mean(test_acc);
    test_acc_std = std(test_acc);
    train_acc_avg = mean(train_acc);
    train_acc_std = std(train_acc);
    diff_acc_avg = mean(diff_acc);
    diff_acc_std = std(diff_acc);
    
    [AEC, EC_std] = get_AEC(error_set);
    [RS, RSQ] = get_ACS(test_acc_avg, diff_acc_avg, labels);
    
end