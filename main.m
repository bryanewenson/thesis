dataset = 'epilepsy';

%Validation Parameters
validation_runs = 30;
holdout_portion = 0.60;
K = 5;
ss_portion = 0.50;

[D, F, L, num_U] = data_read(dataset, 'descend', ss_portion);

%Random Feature Selection (LDA, Holdout)
%rand_n_trials = 150;
%rand_n_select = 30;
%[rand_h_F_idx, rand_h_D_mean] = fs_rand(num_U, D, rand_n_trials, rand_n_select);
%[rand_h_EC, rand_h_test_acc, rand_h_train_acc, rand_h_CV, rand_h_DCV, rand_h_full_EC, rand_h_full_test_acc] = arrayfun(@(fs_idx) lda_holdout(F(:,rand_h_F_idx(fs_idx,:)), L, validation_runs, holdout_portion), (1:rand_n_trials));

%Random Feature Selection (LDA, Holdout)
rand_n_trials = 150;
rand_n_select = 5;
[rand5_km_F_idx, rand5_km_D_mean] = fs_rand(num_U, D, rand_n_trials, rand_n_select);
[rand5_km_EC, rand5_km_test_acc, rand5_km_train_acc, rand5_km_CV, rand5_km_DCV] = arrayfun(@(fs_idx) lda_kfold(F(:,rand5_km_F_idx(fs_idx,:)), L, validation_runs, K), (1:rand_n_trials));

%Random Feature Selection with Varying Sample Size (LDA)
%ssp_n_trials = 100;
%ssp_n_select = 20;
%[ssp_F_idx, ssp_D] = fs_rand(num_U, D, ssp_n_trials, ssp_n_select);
%[ssp_EC, ssp_test_acc, ssp_train_acc, ssp_CV, ssp_DCV] = arrayfun(@(fs_idx) lda_ssp_holdout(F(:,ssp_F_idx(fs_idx,:)), L, validation_runs, holdout_portion), (1:ssp_n_trials));

%Incremental Feature Ranges, Starting at High Effect Size (LDA)
%min = 1;
%max = num_useful_features;
%[b_range_EC, b_range_test_acc, b_range_train_acc, b_range_CV, b_range_DCV] = arrayfun(@(num_f) lda_holdout(F(:,min:min + num_f - 1), L, validation_runs, holdout_portion), (1:max - min + 1));

%Incremental Feature Ranges, Starting at Low Effect Size (LDA)
%min = 1;
%max = num_useful_features;
%[w_range_EC, w_range_test_acc, w_range_train_acc, w_range_CV, w_range_DCV] = arrayfun(@(num_f) lda_holdout(F(:,num_U - num_f + 1:num_U), L, validation_runs, holdout_portion), (1:max - min + 1));



