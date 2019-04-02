function [CV, DCV] = classifier_value(test_accuracy, diff_accuracy, labels)

    num_samples = size(labels, 1);
    pos_samples = sum(labels);
    neg_samples = num_samples - pos_samples;

	base_accuracy = 100 * (max(pos_samples, neg_samples) / num_samples);
    CV = test_accuracy - base_accuracy;
    DCV = 100 * (mean(diff_accuracy) / CV);
    
    CV = 100 * CV;

end

