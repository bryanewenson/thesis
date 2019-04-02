function [EC_avg, avg_testing_accuracy, avg_training_accuracy, CV, DCV, SSP] = eval_lda_ssp(features, labels, validation_runs, holdout_portion)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    num_samples = size(features, 1);
    trunc_samples = randi(num_samples);
    
    training_accuracy = zeros(1,validation_runs);
    training_samples = round(trunc_samples * holdout_portion);
    
    testing_accuracy = zeros(1,validation_runs);
    testing_samples = trunc_samples - training_samples;
    
    diff_accuracy = zeros(1,validation_runs);
    error_set = zeros(validation_runs, testing_samples + 1);
    
    for v = 1:validation_runs
        
        rnd_indices = randperm(trunc_samples);
        rnd_features = features(rnd_indices,:);
        rnd_labels = labels(rnd_indices);

        training_indices = rnd_indices(1:training_samples);
        training_set = rnd_features(training_indices,:);
        training_labels = rnd_labels(training_indices);
        
        %error_set(v,training_indices) = -1;
        
        testing_indices = rnd_indices((training_samples + 1):trunc_samples);
        testing_set = rnd_features(testing_indices,:);
        testing_labels = rnd_labels(testing_indices);
        
        model = fitcdiscr(training_set, training_labels, 'discrimType', 'linear');
       
        training_predictions = predict(model, training_set);
        training_error = abs(training_labels - training_predictions);
        training_accuracy(v) = (training_samples - sum(training_error)) / training_samples;
        
        testing_predictions = predict(model, testing_set);
        testing_error = abs(testing_labels - testing_predictions);
        testing_accuracy(v) = (testing_samples - sum(testing_error)) / testing_samples;
        num_error = sum(testing_error);
        
        diff_accuracy(v) = training_accuracy(v) - testing_accuracy(v);
        
        error_set(v,1:num_error) = testing_indices(logical(testing_error));
    end
    
    EC_avg = error_consistency(error_set);
    
    %Calculate average accuracies and accuracy difference
    avg_testing_accuracy = 100 * mean(testing_accuracy);
    avg_training_accuracy = 100 * mean(training_accuracy);
    
    [CV, DCV] = classifier_value(avg_testing_accuracy, diff_accuracy, labels);
    
    SSP = 100 * (trunc_samples / num_samples);
    
end