%{ 
Description:
    This function reads a specified MATLAB dataset and returns the data as
    well as some useful metadata pertaining to the data. It also has the
    ability to curate the features somewhat based on a discriminatory 
    quality.

Input:
    - dataset: This is a string containing the name of the dataset to be
    loaded. It is assumed that this dataset is in a location on the
    execution path, or that the absolute path has been passed. Note that
    the file extension is not needed. 
    - trim_threshold: This is a float value that is ignored if outside 
    (0,1]. Otherwise, any features containing a value with a relative 
    frequency above the given value will be removed from the feature set.

Output:
    - D: A matrix of size Nx1. This contains the effect size for each
    feature in F. 
    - F: A matrix of size SxN, where S is the number of samples. This
    contains the entire set of features of the desired dataset, barring any
    features excluded due to the trim_threshold or with a non-numeric
    effect size value. Each row represents a sample, while each column is a
    single feature.
    - L: A matrix of size Sx1. This contains the labels associated with each
    sample in F.
    - N: The final number of features in the dataset.
%}
function [D, F, L, N] = data_read(dataset, trim_threshold, trim_esnan)

    load(dataset);

    if trim_threshold > 0 && trim_threshold <= 1
        %Find all features that fall over the given trimming threshold
        U = arrayfun(@(col) trim(measurements(:,col), trim_threshold, ...
            samples), (1:num_features))';
        
        %Remove any of the designated features
        measurements(:,U) = [];
    end
    
    N = size(measurements, 2);
    L = labels;

    %Calculate the effect size for the set of features, excluding any 
    %features that have a non-numeric score.
    D = arrayfun(@(col) get_effect_size(measurements(:,col), ...
        positive_indices, negative_indices), (1:N))';
    
    if trim_esnan
        measurements(:,isnan(D)) = [];
        D(isnan(D)) = [];
    end
    
    F = measurements;
    N = size(measurements, 2);

end
