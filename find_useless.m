function is_useless = find_useless(C, V)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if size(unique(C)) < 2
        is_useless = true;
    else
        is_useless = any(histcounts(C, unique(C)) > V);
    end
    
end