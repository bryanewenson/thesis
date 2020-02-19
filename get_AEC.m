function [AEC, EC_std] = get_AEC(error_sets)

    num_sets = size(error_sets,1);
    EC = zeros(num_sets, num_sets);
    
    for i = 1:num_sets
        EC(i,i) = 1.0;
        for j = i+1:num_sets
            
            err_intersection = intersect(error_sets(i,:),error_sets(j,:));
            err_union = union(error_sets(i,:),error_sets(j,:));
            
            EC_tmp = (size(err_intersection,2)-1) / (size(err_union, 2) - 1);
            
            if size(err_union, 2) == 1  %Two empty error sets
                EC(i,j) = 1;
            elseif EC_tmp == 0          %Zero EC
                EC(i,j) = -1;
            else
                EC(i,j) = EC_tmp;
            end
               
            EC(j,i) = EC(i,j);
        end
    end
    
    %Summarize EC
    vect_EC = 100 * reshape(tril(EC,-1), 1, num_sets * num_sets);
    vect_EC(vect_EC == 0) = [];
    vect_EC(vect_EC == -100) = 0;
    EC_std = std(vect_EC);
    AEC = mean(vect_EC);
    
    if isnan(AEC)
        disp("EC_avg nan");
    end
    if AEC <= 0
       disp("Negative"); 
    end
    
end