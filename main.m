function results = main(varargin)
%% Parameters
%{    
** GENERAL PARAMETERS **
- n_trials: The number of times to repeat the desired experiments. Note
that this differs from the number of validation runs to perform. This
amount affects how many times the entire validation process is repeated
from scratch, usually with parameter being varied each time.  

NOTE: The following can all be specified as function parameters in the 
order that they appear here. Unless specified otherwise, they can only be a
a single integer. The values here will be used if not passed as parameters.

- method_keyval: Numeric value representing which classifier type is being
selected. Several methods can be used in one instance(though they will not
execute simultaneously) by providing an array of several values. The values
are:
    - 1 = Linear Discriminant Analysis
    - 2 = Aritificial Neural Network
    - 3 = Support Vector Machine
    - 4 = Random Forest
    - 5 = Convolutional Neural Network

- dataset_keyval: This value determines the dataset(s) to use for this
experiment. Several can be selected by providing an array.  The values are:
    - 1 = Arrhythmia, 2 = Schizophrenia, 3 = MNIST, 4 = Abalone
    - 5 = Autism, 6 = Banknote, 7 = Diabetes, 8 = Liver, 9 = Parkinsons
    - 10 = Sonar, 11 = SPECT, 12 = SPECTD, 13 = Transfusion, 14 = Waveform
    - 15 = Wine

- fs_keyval: This selection governs the method of feature selection.
Descriptions of the different methods are in the associated paper. The 
values are:
    - 1 = Random 
    - 2 = Top
    - 3 = Climb
    - 0 = None

- plot_type_keyval: This value determines which data is plotted at the end
of the function. The values are:
    -1 = Testing/Training accuracy over the indices of the underlying
    features.
    -2 = Difference between training/testing accuracy over the average
    effect size of the underlying features.
    -3 = Average error consistency over the average effect size of the
    underlying features. 
    -4 = Average error consistency and testing accuracy over the
    subsampling portion. 
    -0 = No plot

- valid_keyval: This determines the validation method. The values are:
    -1 = Holdout
    -2 = K-Fold
%}

n_trials            = 10;
method_keyval       = [1];
dataset_keyval      = [1];
fs_keyval           = 1;
plot_type_keyval    = 4;
valid_keyval        = 2;
 
%{
** VALIDATION PARAMETERS **
- valid_rand: Setting to false will cause each trial to have the exact 
same samples belonging to the testing and training sets respectively.
- valid_runs: The number of times to repeat the classification process with
different distribution of training and testing sets. If the K-Fold method
is selected, the number of runs is reduced by a factor equal to K. 
- holdout_ratio: If holdout is selected, this is the portion of the samples
reserved for the training set. 
- K: Value of K in the K-Fold method.
%}

valid_rand          = true;
valid_runs          = 15;
holdout_ratio       = 0.60;
K                   = 5;

%{
** FEATURE SELECTION PARAMETERS **
- sort_order: The order in which the features are sorted according to
effect size. 
- n_select: The number of features to select from the feature set. This has
different effects based on the chosen fs method. 
NOTE: The rest are explained in detail within the associated thesis. 
%}

sort_order          = 'descend';
n_select_set        = [5];          % Number of features to select. When using the climb method, refers to the amount of features to add. Gets set to the total number of features if set to 0.
n_shift_set         = [0];          % Number of features to shift away from the beginning of the potential feature set
fixed_validation    = true;         % Perform variable feature selection, meaning that the selected features may vary between trials. If false, random will assign the same features for each trial, otherwise each trial will have a new random set of features. No other method is affected. 
trim_threshold      = 1;            % If within (0,1], enforces a relative frequency threshold on included features. Any feature containing a value with relative frequency above the threshold is removed from the experiment.

%{
** SUBSAMPLING PARAMETERS **
- perf_ssp: Set true to perform subsampling. 
- rnd_ssp: Set true to randomly generate SSP values. Process explained in
depth within thesis.
- strict_subsampling: Set to true to enforce strict subsampling, explained
within thesis along with ssp_max and min_samples. 
- full_effect_size: If true, calculate effect size of features before
subsampling. Otherwise done after subsampling. 
%}
perf_ssp            = true;        % Perform variable subsampling?
strict_subsampling  = false;         % Restrict all subsampling to an initial selection of an ssp_max subsample. 
ssp_max             = 0.025;         % The largest allowable subsampling portion
ssp_min             = 0.025;         % The smallest allowable subsampling portion
rnd_ssp             = false;        % Use random ssp values?   IF false, use linspace between min and max
min_samples         = 10;          % Minimum sample size to test, should be >= K if using K-Fold

%PLOTTING PARAMETERS
shared_bounds       = true;         % Use the same bounds for each experiment
full_effect_size    = true;         % Measure effect size using full dataset? Only affects strict subsampling

iterative_saves     = false;        % Save after every experiment?

%% Argument Handling
if nargin ~= 0 && nargin ~= 8 && nargin ~= 3 && nargin ~= 6
    disp("Invalid number of input arguments to function Main.");
    return
end

proc_idx = 0;
proc_trials = 1:n_trials;
tag = "def";

if nargin == 8
    proc_idx = varargin{1};
    proc_trials = varargin{2};
    tag = varargin{3};
    method_keyval = varargin{4};
    dataset_keyval = varargin{5};
    fs_keyval = varargin{6};
    plot_type_keyval = varargin{7};
    valid_keyval = varargin{8};
elseif nargin == 5
    method_keyval = varargin{1};
    dataset_keyval = varargin{2};
    fs_keyval = varargin{3};
    plot_type_keyval = varargin{4};
    valid_keyval = varargin{5};
elseif nargin == 3
    proc_idx = varargin{1};
    proc_trials = varargin{2};
    tag = varargin{3};

    if max(proc_trials) > n_trials
        disp("Error: No proc_trials values allowed above n_trials");
        return
    end
end

%% Preprocessing

%Adjust the Matlab execution path as necessary
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

%Disable plotting if running in parallel
if size(proc_trials,2) < n_trials
    plot_type_keyval = 0;
end

%Determine the name of the selected dataset
n_datasets = size(dataset_keyval,2);
dataset_names = ["Arrhythmia", "Schizophrenia", "MNIST", ...
    "Abalone", "Autism", "Banknote", "Diabetes", "Liver", "Parkinsons", ...
    "Sonar", "SPECT", "SPECTD", "Transfusion", "Waveform", "Wine"];

%Determine the name and handle of the selected ML method
n_methods = size(method_keyval,2);
method_names = ["LDA", "ANN" ,"SVM", "RF", "CNN"];
M_name = method_names(method_keyval);

%Determine the number of feature selection methods being used
n_select_size = size(n_select_set, 2);
n_shift_size = size(n_shift_set, 2);
n_fs = n_select_size * n_shift_size;

%Determine the number of experiments being performed
n_experiments = n_methods * n_datasets * n_fs;

%Generate the appropriate string/handle for the validation method.
validation_names = ["holdout", "kfold"];
V_handle = str2func(sprintf('valid_%s', validation_names(valid_keyval)));
validation_names = [sprintf("%0.1f%% Holdout", 100 * holdout_ratio), ...
    sprintf("%d Fold", K)];
V_name = validation_names(valid_keyval);

%Adjust validation parameters based on chosen validation method
if valid_keyval == 1
    valid_param = holdout_ratio;
else
    valid_param = K;
    valid_runs = round(valid_runs / K);
end

%Adjust perf_vfs if necessary
if fs_keyval == 2 || fs_keyval == 0
    fixed_validation = false;
elseif fs_keyval == 3
    fixed_validation = true;
end

%% Experiment

idx_exp = 1;

% DATASET LOOP
for idx_dataset = 1:n_datasets

    dataset = dataset_names(dataset_keyval(idx_dataset));

    %Ensures that the dataset can be found by Matlab
    if ~(exist(sprintf("%s.mat", dataset), 'file'))
        error('Data cannot be found. Make sure its directory is on path.')
    end

    [D_full, F_full, L_full, N] = data_read(dataset, trim_threshold);
    
    if strict_subsampling
        rest_idx = subsample(L, ssp_max);
        L = L(rest_idx);
        F = F(rest_idx, :);
        if ~full_effect_size
            D = arrayfun(@(col) get_effect_size(F_full(:,col), ...
            find(L_full==1), find(L_full==0)), (1:N))';
        else
            D = D_full;
        end
    else
        D = D_full;
        F = F_full;
        L = L_full;
    end
    
    if perf_ssp
        ssp_min = max(ssp_min, min_samples/size(L,1));
            
        if ssp_max < ssp_min
            error('Error: min_ssp cannot be greater than max_ssp.');
        end
            
        if rnd_ssp
            ssp_set = rand(1,n_trials) .* (ssp_max - ssp_min) + ssp_min;
        else
            ssp_set = linspace(ssp_min, ssp_max, n_trials); 
        end

        %Generate the subsampling selections
        S_idx = arrayfun(@(q) subsample(L, ssp_set(q)), ...
            (1:n_trials), "UniformOutput", false);
        results(:).ssp = ssp_set;
    end 
    
    % FEATURE SELECTION LOOP
    for idx_fs = 1:n_fs
        
        %Set the FS parameters for this experiment
        if n_shift_size == 1
            n_select = n_select_set(idx_fs);
            n_shift = n_shift_set(1);
        elseif n_select_size == 1
            n_select = n_select_set(1);
            n_shift = n_shift_set(idx_fs);
        else
            n_select = n_select_set(floor((idx_fs - 1) / n_shift_size) + 1);
            n_shift = n_shift_set(mod(idx_fs - 1, size(n_shift_size)) + 1);
        end
    
        if n_select == 0 || n_select > N - n_shift
            n_select = N - n_shift;
        end

        %Ensure that n_trials matches the number of features to select
        if fs_keyval == 3
            n_trials = n_select;
            proc_trials = n_select;
        end
        
        %Perform feature selection
        switch fs_keyval
            case 1      % Random FS
                [F_idx, D_mean] = fs_rand(D, n_select, n_trials);

            case 2      % Top FS 
                [F_idx, D_mean] = fs_top(D, n_select, sort_order);

            case 3      % Climb FS
                [F_idx, D_mean] = fs_climb(D, n_select, n_shift, sort_order);

            otherwise   % No FS
                F_idx = 1:N;
                D_mean = mean(D);
        end

        %need a matrix F_idx where each row contains the chosen features for
        %that trial
        
        % ML METHOD LOOP
        for idx_method = 1:n_methods    
            %Get handle to appropriate ML method
            method = M_name(idx_method);
            M = str2func(sprintf('predict_%s', lower(method)));

            %Save significant parameters for each experiment
            results(idx_exp).dataset = dataset;
            results(idx_exp).method = method;
            results(idx_exp).validation = V_name;
            results(idx_exp).D_mean = D_mean;
            results(idx_exp).n_select = n_select;
            results(idx_exp).n_shift = n_shift;
            results(idx_exp).sort_order = sort_order;
            results(idx_exp).ssp_max = ssp_max;

            %Evaluate
            if perf_ssp
                results(idx_exp).ssp = ssp_set;
                
                [results(idx_exp).test_acc_avg, ...
                    results(idx_exp).test_acc_std, ...
                    results(idx_exp).train_acc_avg, ...
                    results(idx_exp).train_acc_std, ...
                    results(idx_exp).diff_acc_avg, ...
                    results(idx_exp).diff_acc_std, ...
                    results(idx_exp).AEC, ...
                    results(idx_exp).EC_std, ...
                    results(idx_exp).ACS, ...
                    results(idx_exp).DACS]...
                    = arrayfun(@(t_idx) V_handle ...
                    (F(cell2mat(S_idx(t_idx)),F_idx), ...
                    L(cell2mat(S_idx(t_idx))), valid_runs, valid_param,...
                    M, valid_rand), (proc_trials));

            elseif ~fixed_validation
                if fs_keyval == 3
                    n_feat= arrayfun(@(idx) sum(F_idx(idx,:)~=0),(1:n_trials));
                    F_end = arrayfun(@(idx) sum(n_feat(1:idx)), 1:n_trials);
                    F_start = [1,F_end(1:end-1) + 1];
                    F_idx = reshape(F_idx',[1,n_select * n_trials]);
                    F_idx(F_idx == 0) = [];
                else
                    F_end = ((1:n_trials) .* n_select);
                    F_start = (0:n_trials-1) .* n_select + 1;
                    F_idx = reshape(F_idx',[1,n_select * n_trials]);
                end

                [results(idx_exp).test_acc_avg, ...
                    results(idx_exp).test_acc_std, ...
                    results(idx_exp).train_acc_avg, ...
                    results(idx_exp).train_acc_std, ...
                    results(idx_exp).diff_acc_avg, ...
                    results(idx_exp).diff_acc_std, ...
                    results(idx_exp).AEC, ...
                    results(idx_exp).EC_std, ...
                    results(idx_exp).ACS, ...
                    results(idx_exp).DACS]...
                    = arrayfun(@(t_idx) V_handle ...
                    (F(:,F_idx(F_start(t_idx):F_end(t_idx))), L, valid_runs,...
                    valid_param, M, valid_rand), (proc_trials));
            elseif ~fixed_validation && perf_ssp
                results(idx_exp).ssp = ssp_set;

                if fs_keyval == 3
                    n_feat= arrayfun(@(idx) sum(F_idx(idx,:)~=0),(1:n_trials));
                    F_end = arrayfun(@(idx) sum(n_feat(1:idx)), 1:n_trials);
                    F_start = [1,F_end(1:end-1) + 1];
                    F_idx = reshape(F_idx',[1,n_select * n_trials]);
                    F_idx(F_idx == 0) = [];
                else
                    F_end = ((1:n_trials) .* n_select);
                    F_start = (0:n_trials-1) .* n_select + 1;
                    F_idx = reshape(F_idx',[1,n_select * n_trials]);
                end

                [results(idx_exp).test_acc_avg, ...
                    results(idx_exp).test_acc_std, ...
                    results(idx_exp).train_acc_avg, ...
                    results(idx_exp).train_acc_std, ...
                    results(idx_exp).diff_acc_avg, ...
                    results(idx_exp).diff_acc_std, ...
                    results(idx_exp).AEC, ...
                    results(idx_exp).EC_std, ...
                    results(idx_exp).ACS, ...
                    results(idx_exp).DACS]...
                    = arrayfun(@(t_idx) V_handle ...
                    (F(cell2mat(S_idx(t_idx)),F_idx(F_start(t_idx):F_end(t_idx))), L(cell2mat(S_idx(t_idx))), valid_runs,...
                    valid_param, M, valid_rand), (proc_trials));
            else
                [results(idx_exp).test_acc_avg, ...
                    results(idx_exp).test_acc_std, ...
                    results(idx_exp).train_acc_avg, ...
                    results(idx_exp).train_acc_std, ...
                    results(idx_exp).diff_acc_avg, ...
                    results(idx_exp).diff_acc_std, ...
                    results(idx_exp).AEC, ...
                    results(idx_exp).EC_std, ...
                    results(idx_exp).RS, ...
                    results(idx_exp).QRS]...
                    = arrayfun(@(t_idx) V_handle (F(:,F_idx), L, valid_runs,...
                    valid_param, M, valid_rand), (proc_trials));
            end

            idx_exp = idx_exp + 1;
            
            if iterative_saves
                %Save workspace for each experiment with unique identifier
                c = fix(clock);
                save(sprintf("ResultsWP[%s][%d][%s_%s][%d-%d_%d-%d-%d]",... 
                    tag,proc_idx,dataset,M_name(idx_method),c(2),c(3),...
                    c(4),c(5),c(6)));
            end    
        end
    end
end

%Save final results
c = fix(clock);
save(sprintf("Results[%s][%d][%d-%d_%d-%d-%d]", tag, proc_idx,...
    c(2), c(3), c(4), c(5), c(6)));

%Plot Results
if plot_type_keyval ~= 0
    figures = plot_results(plot_type_keyval, results, shared_bounds);
end
