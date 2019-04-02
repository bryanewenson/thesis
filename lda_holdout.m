function [test_EC, avg_testing_accuracy, avg_training_accuracy, CV, DCV, avg_full_accuracy, full_EC] = lda_holdout(features, labels, validation_runs, holdout_portion)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    num_samples = size(features, 1);
    
    training_accuracy = zeros(1, validation_runs);
    training_samples = round(num_samples * holdout_portion);
    
    testing_accuracy = zeros(1, validation_runs);
    testing_samples = num_samples - training_samples;
    test_error_set = zeros(validation_runs, testing_samples + 1);
    
    full_accuracy = zeros(1, validation_runs);
    full_error_set = zeros(validation_runs, num_samples + 1);
    diff_accuracy = zeros(1,validation_runs);
    
    for v = 1:validation_runs
        rnd_indices = randperm(num_samples);

        training_indices = rnd_indices(1:training_samples);
        training_set = features(training_indices,:);
        training_labels = labels(training_indices);
        
        testing_indices = rnd_indices((training_samples + 1):num_samples);
        testing_set = features(testing_indices,:);
        testing_labels = labels(testing_indices);
        
        model = fitcdiscr(training_set, training_labels, 'discrimType', 'linear');
       
        training_predictions = predict(model, training_set);
        training_error = abs(training_labels - training_predictions);
        training_accuracy(v) = (training_samples - sum(training_error)) / training_samples;
        
        testing_predictions = predict(model, testing_set);
        testing_error = abs(testing_labels - testing_predictions);
        testing_accuracy(v) = (testing_samples - sum(testing_error)) / testing_samples;
        
        diff_accuracy(v) = training_accuracy(v) - testing_accuracy(v);
        
        num_test_error = sum(testing_error);
        test_error_set(v,1:num_test_error) = testing_indices(logical(testing_error));
    
        full_predictions = predict(model, features);
        full_error = abs(labels - full_predictions);
        full_accuracy(v) = (num_samples - sum(full_error)) / num_samples;
        
        num_full_error = sum(full_error);
        full_error_set(v,1:num_full_error) = find(full_error == 1);
    
    end
    
    test_EC = error_consistency(test_error_set);
    full_EC = error_consistency(full_error_set);
    
    %Calculate average accuracies and accuracy difference
    avg_testing_accuracy = 100 * mean(testing_accuracy);
    avg_training_accuracy = 100 * mean(training_accuracy);
    avg_full_accuracy = 100 * mean(full_accuracy);
    
    [CV, DCV] = classifier_value(avg_testing_accuracy, diff_accuracy, labels);
    
    %Note that the full version is still only trained on 60% of the samples
    
end