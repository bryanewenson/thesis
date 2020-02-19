function [F_idx, D_mean] = fs_top(D, n_select, sort_order)

    [sorted_D, sort_idx] = sort(D, sort_order);

    F_idx = sort_idx(1:n_select)';
    D_mean = mean(sorted_D(1:n_select));

end