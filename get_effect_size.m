function cohens = get_effect_size(measurement, positive_indices, negative_indices)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    positive_measurements = measurement(positive_indices);
    negative_measurements = measurement(negative_indices);
        
    positive_mean = mean(positive_measurements);
    negative_mean = mean(negative_measurements);
        
    cohens = abs(positive_mean - negative_mean)/std(measurement);
    
end
