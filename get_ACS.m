function [ACS, DACS] = get_ACS(test_accuracy, diff_accuracy, labels)

    num_samples = size(labels, 1);
    pos_samples = sum(labels);
    neg_samples = num_samples - pos_samples;

	base_accuracy = 100 * (max(pos_samples, neg_samples) / num_samples);
    ACS = test_accuracy - base_accuracy;
    DACS = 100 * (mean(diff_accuracy) / ACS);
    
    ACS = 100 * ACS;

end

