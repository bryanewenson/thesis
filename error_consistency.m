function EC_avg = error_consistency(error_sets)

    num_sets = size(error_sets,1);
    
    EC = zeros(num_sets, num_sets);
    EC_sum = 0;
    n_nan = 0;
    
    for i = 1:num_sets
        EC(i,i) = 1.0;
        for j = i+1:num_sets
            
            err_intersection = intersect(error_sets(i,:),error_sets(j,:));
            err_union = union(error_sets(i,:),error_sets(j,:));
            
            EC_tmp = (size(err_intersection,2)-1) / (size(err_union, 2) - 1);
            
            %Keep track of how many have been excluded
            
            if size(err_union, 2) == 1
                %Handles the case of two empty error sets
                EC(i,j) = -1;
                n_nan = n_nan + 1;
            else
                %Normal Case
                EC_sum = EC_sum + EC_tmp;
                EC(i,j) = EC_tmp;
            end
               
            EC(j,i) = EC(i,j);
        end
    end
    
    %Summarize EC
    mat_size = ((num_sets * (num_sets - 1)) / 2) - n_nan;
    EC_avg = 100 * (EC_sum / mat_size);
    
    if isnan(EC_avg)
        disp("EC_avg nan");
    end
    
end