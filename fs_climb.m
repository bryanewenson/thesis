%{ 
Description:


Input:


Output:

%}
function [F_idx, D_mean] = fs_climb(D, n_select, n_shift, sort_order)

    [sorted_D, sort_idx] = sort(D, sort_order);
    
    if n_shift > 0
        sorted_D(1:n_shift) = [];
        sort_idx(1:n_shift) = [];
    end

    n_features = size(sorted_D,1);

    if n_select == 0 || n_select > n_features
        n_select = n_features;
    end
    
    F_idx = zeros(n_select, n_select);
    D_mean = zeros(n_select,1);
    
    for i = 1:n_select
        F_idx(i,1:i) = sort_idx(1:i);
        D_mean(i) = mean(sorted_D(1:i));
    
    end

end