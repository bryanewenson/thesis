function is_trimmed = trim(measurement, trim_threshold, samples)

    if size(unique(measurement)) < 2
        is_trimmed = true;
    else
        is_trimmed = any(histcounts(measurement, unique(measurement)) > trim_threshold * samples);
    end
    
end