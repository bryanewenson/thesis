function [D, F, L, num_useful_features] = data_read_raw(dataset)

    load(dataset);
    
    num_useful_features = size(measurements, 2);
    L = labels;

    %Calculate Cohens D for the remaining features
    D = arrayfun(@(col) get_effect_size(measurements(:,col), positive_indices, negative_indices), (1:num_useful_features))';
    D(isnan(D)) = 0;

    F = measurements;

end
