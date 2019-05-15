clear;

%% Parameters
% General Parameters
n_trials            = 150;
validation_runs     = 100;
validation_keyval   = 2;            % 1 = Holdout, 2 = K-Fold
holdout_portion     = 0.60;         % Only used if Holdout selected
K                   = 5;            % Only used if K-Fold selected
sort_order          = 'descend';    % 'ascend' or 'descend'
method_keyval       = 5;            % 1 = LDA, 2 = ANN, 3 = SVM, 4 = RF, 5 = CNN
dataset_keyval      = 4;            % 1 = Arrhythmia, 2 = Schizophrenia, 3 = Epilepsy, 4 = MNIST
fitline             = false;        % Place a line of best fit on the final plots

% Plotting Parameters
plot_type_keyval    = 2;            % 1 = ECA/D_mean, 2 = ECA/SSP            

% Feature Selection Parameters
n_select            = 25;           % Number of features to select

% Subsampling Parameters
rnd_ssp             = false;        % Use random ssp values?
min_samples         = 100;           % Minimum sample size to test, should be >= K
if ~rnd_ssp
    ssp_set         = [1.00, 0.50, 0.25, 0.10, 0.05, 0.025];
    n_experiments = size(ssp_set,2);
else
    n_experiments = 1;
end

full_effect_size    = true;         % Use entire sample set for effect size calculations?

%% Preprocessing

%Makes any necessary additions to the Matlab search path
codepath = mfilename('fullpath');
codepath = codepath(1:end-5);
datapath = strcat(codepath,'\Data');

path_cells = regexp(path, pathsep, 'split');
if ~any(strcmpi(datapath, path_cells))
    addpath(datapath);
end
if ~any(strcmpi(codepath, path_cells))
    addpath(codepath);
end
clear path_cells;

%Determines the name of the selected dataset
dataset_names = ["Arrhythmia", "Schizophrenia", "Epilepsy", "MNIST"];
dataset = dataset_names(dataset_keyval);

%Ensures that the dataset can be found by Matlab
if exist(sprintf("%s.mat", dataset), 'file')
    [D, F, L, n_useful] = data_read(dataset, sort_order);
else    
    disp("Dataset cannot be found. Make sure its directory is added to path.")
    return;
end

%Determines the name and handle of the selected ML method
method_names = ["LDA", "ANN" ,"SVM", "RF", "CNN"];
M_name = method_names(method_keyval);
M = str2func(sprintf('%s_predict', lower(M_name)));

%Generates the appropriate string for the selected validation settings
validation_names = [sprintf("%0.1f%% Holdout", 100 * holdout_portion), sprintf("%d Fold", K)];
V_name = validation_names(validation_keyval);

%Adjust the number of validation runs if KFold is selected
if validation_keyval == 2
    validation_runs = validation_runs / K;
end

%Initialize the results structure
if ~exist('results', 'var')
        results = init_results(plot_type_keyval, n_experiments, n_trials, n_select);
end

%% Feature Selection

%Random Feature Selection
%[F_idx, D_mean] = fs_rand(n_useful, D, n_trials, n_select);
    
%Best Feature Selection (By Effect Size)
%F_idx = 1:n_select;
%D_mean = mean(D(F_idx));

%Incremental Feature Selection *** WIP ***

%Sliding Window Feature Selection (By Effect Size) *** WIP *** 
%F_idx = fs_wind(n_useful, D, window_sz);

%Only Useful Features
%F_idx = 1:n_useful;

%No Feature Selection (All Features Used)
[D, F, L, n_useful] = data_read_raw(dataset);
F_idx = 1:n_useful;

%% Random Feature Selection (LDA, Holdout)
%rand_n_trials = 150;
%rand_n_select = 30;
%[rand_h_F_idx, rand_h_D_mean] = fs_rand(num_U, D, rand_n_trials, rand_n_select);
%[rand_h_EC, rand_h_test_acc, rand_h_train_acc, rand_h_CV, rand_h_DCV, rand_h_full_EC, rand_h_full_test_acc] = arrayfun(@(fs_idx) lda_holdout(F(:,rand_h_F_idx(fs_idx,:)), L, validation_runs, holdout_portion), (1:rand_n_trials));

%% Random Feature Selection with Varying Sample Size KFold

%for i = 1:n_experiments
%    [D, F, L, num_U] = data_read(dataset, sort_order, ssp_set(i));
%    
%    [selected_idx, results(i).D_mean] = fs_rand(num_U, D, n_trials, n_select);
%    results(i).F_idx = selected_idx;
%    
%    [results(i).EC_avg, results(i).test_acc, results(i).train_acc, results(i).CV, results(i).DCV] = arrayfun(@(fs_idx) kfold(F(:,selected_idx(fs_idx,:)), L, validation_runs, K, M), (1:n_trials));    
%end

%% Best Feature Selection with Varying Sample Size KFold

if rnd_ssp
    %Generate the set of subsampling portions
    ssp_set = rand(1,n_trials);
    ssp_replace = find(ssp_set < (min_samples / size(L,1)));

    %Replace any of the ssp values that reduce the sample size below minimum
    while ~isempty(ssp_replace)
        ssp_set(ssp_replace) = rand(1,size(ssp_replace,2));
        ssp_replace = find(ssp_set < (min_samples / size(L,1)));
    end
else
   ssp_set = linspace(min_samples / size(L,1), 1.0, n_trials); 
end
    
%Generate the subsampling selections
S_idx = arrayfun(@(i) subsample(L, ssp_set(i)), (1:n_trials), 'UniformOutput', false);

[results(1).EC_avg, results(1).test_acc, results(1).train_acc, results(1).CV, results(1).DCV] = arrayfun(@(t_idx) kfold (F(cell2mat(S_idx(t_idx)),F_idx), L(cell2mat(S_idx(t_idx))), validation_runs, K, M), (1:n_trials));
results(1).ssp = ssp_set;

%% Random Feature Selection (LDA, KFold)
%rand_n_trials = 100;
%rand_n_select = 20;
%validation_runs = validation_runs / K;
%[F_idx, D] = fs_rand(num_U, D, rand_n_trials, rand_n_select);
%[EC, test_acc, train_acc, CV, DCV] = arrayfun(@(fs_idx) lda_holdout(F(:,F_idx(fs_idx,:)), L, validation_runs, holdout_portion), (1:rand_n_trials));

%% Incremental Feature Ranges, Starting at High Effect Size (LDA)
%min = 1;
%max = num_useful_features;
%[b_range_EC, b_range_test_acc, b_range_train_acc, b_range_CV, b_range_DCV] = arrayfun(@(num_f) lda_holdout(F(:,min:min + num_f - 1), L, validation_runs, holdout_portion), (1:max - min + 1));

%% Incremental Feature Ranges, Starting at Low Effect Size (LDA)
%min = 1;
%max = num_useful_features;
%[w_range_EC, w_range_test_acc, w_range_train_acc, w_range_CV, w_range_DCV] = arrayfun(@(num_f) lda_holdout(F(:,num_U - num_f + 1:num_U), L, validation_runs, holdout_portion), (1:max - min + 1));

%% Plot Results

plot_info = get_plot_info(plot_type_keyval, results, dataset, V_name, M_name);

plot_info.x_min = min(arrayfun(@(i) min(plot_info.x(i, :)), (1:n_experiments)));
plot_info.x_max = max(arrayfun(@(i) max(plot_info.x(i, :)), (1:n_experiments)));

plot_info.y_min = min(arrayfun(@(i) min(plot_info.y(i, :)), (1:n_experiments)));
plot_info.y_max = max(arrayfun(@(i) max(plot_info.y(i, :)), (1:n_experiments)));

fig = plot_results(n_experiments, plot_info, fitline); 