function S_idx = subsample(L, ssp)

    neg_idx = find(L == 0);
    neg_samples = size(neg_idx,1);
    neg_ssp_samples = round(neg_samples * ssp);
    neg_idx = randsample(neg_idx, neg_ssp_samples);
    
    pos_idx = find(L == 1);
    pos_samples = size(pos_idx,1);
    pos_ssp_samples = round(pos_samples * ssp);
    pos_idx = randsample(pos_idx, pos_ssp_samples);

    S_idx = [neg_idx;pos_idx];
    
    %Randomize the order of the indices
    S_idx = S_idx(randperm(neg_ssp_samples + pos_ssp_samples));
    
end

