function [RS, RSQ] = get_RSQ(test_accuracy, diff_accuracy, labels)

    num_samples = size(labels, 1);
    pos_samples = sum(labels);
    neg_samples = num_samples - pos_samples;

	base_accuracy = 100 * (max(pos_samples, neg_samples) / num_samples);
    RS = test_accuracy - base_accuracy;
    RSQ = (RS / diff_accuracy);
    
end

