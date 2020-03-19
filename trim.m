function is_trimmed = trim(measurement, trim_threshold, samples)

    if size(unique(measurement),1) == 1
        is_trimmed = true;
    else
        is_trimmed = max(groupcounts(measurement)) > (trim_threshold * samples);
    end
    
end