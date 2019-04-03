function [D, F, L, num_useful_features] = data_read(dataset, sort_order, ss_portion)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    try
        load(dataset);

        ss_pos_samples = round(positive_samples * ss_portion); 
        ss_pos_indices = positive_indices(randsample(positive_samples, ss_pos_samples));
        ss_neg_samples = round(negative_samples * ss_portion);
        ss_neg_indices = negative_indices(randsample(negative_samples, ss_neg_samples));

        F = [measurements(ss_pos_indices, :);measurements(ss_neg_indices, :)];
        L = [labels(ss_pos_indices);labels(ss_neg_indices)];

        positive_indices = 1:ss_pos_samples;
        negative_indices = (ss_pos_samples + 1):ss_pos_samples + ss_neg_samples;
        
        %Find the indices of all useless features for removal
        U = arrayfun(@(col) find_useless(F(:,col), samples * 0.50), (1:num_features))';

        F(:,U) = [];
        num_features = size(F, 2);

        %Calculate Cohens D for the remaining features
        D = arrayfun(@(col) get_effect_size(F(:,col), positive_indices, negative_indices), (1:num_features))';
        D(isnan(D) | D == 0) = [];

        try
            [D, sorted_indices] = sort(D, sort_order);
            num_useful_features = size(D,1);
            F = F(:,sorted_indices);
        catch
           disp('Invalid sort order');

            D = 0;
            F = 0;
            L = 0;
            num_useful_features = 0;
        end
            
    catch
        disp('Error loading dataset');
    
        D = 0;
        F = 0;
        L = 0;
        num_useful_features = 0;
    end
end

