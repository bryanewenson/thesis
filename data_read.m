function [D, F, L, num_useful_features] = data_read(dataset, sort_order)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    try
        load(dataset);

        %Find the indices of all useless features for removal
        U = arrayfun(@(col) find_useless(measurements(:,col), samples * 0.50), (1:num_features))';

        measurements(:,U) = [];
        num_features = size(measurements, 2);
        L = labels;

        %Calculate Cohens D for the remaining features
        D = arrayfun(@(col) get_effect_size(measurements(:,col), positive_indices, negative_indices), (1:num_features))';
        D(isnan(D) | D == 0) = [];

        try
            [D, sorted_indices] = sort(D, sort_order);
            min_idx = 21;
            max_idx = 40;
            num_useful_features = size(sorted_indices,1);
            feature_range = min_idx:max_idx;
            F = measurements(:,sorted_indices);
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

