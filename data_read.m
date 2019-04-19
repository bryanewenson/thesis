function [D, F, L, num_useful_features] = data_read(dataset, sort_order)

    load(dataset);

    %Find the indices of all useless features
    U = arrayfun(@(col) find_useless(measurements(:,col), samples * 0.50), (1:num_features))';

    %Remove useless features
    measurements(:,U) = [];
    num_features = size(measurements, 2);
    L = labels;

    %Calculate Cohens D for the remaining features
    D = arrayfun(@(col) get_effect_size(measurements(:,col), positive_indices, negative_indices), (1:num_features))';
    D(isnan(D) | D == 0) = [];

    [D, sorted_indices] = sort(D, sort_order);
    num_useful_features = size(sorted_indices,1);
    F = measurements(:,sorted_indices);

end
