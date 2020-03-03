function full_results = para_gather(n_proc, tag)

    rf_dir = string(pwd) + '\' + "Results[" + tag + "]*";
    result_files = dir(rf_dir);

    idx = zeros(1,n_proc);
    for x = 1:n_proc
        [begin,fin] = regexp(result_files(x).name, "\[\d+\]") ;
        idx(x) = str2num(result_files(x).name(begin+1:fin-1));
    end
    
    [~, order] = sort(idx);
    result_files = result_files(order);
    
    disp("Processing " + result_files(1).name);
    load(result_files(1).name);
    full_results = results;
    num_results = size(results,2);
    
    for y = 2:n_proc
        disp("Processing " + result_files(y).name);

        load(result_files(y).name);

        for x = 1:num_results
            full_results(x).test_acc_avg = [full_results(x).test_acc_avg,results(x).test_acc_avg];
            full_results(x).test_acc_std = [full_results(x).test_acc_std,results(x).test_acc_std];
            full_results(x).train_acc_avg = [full_results(x).train_acc_avg,results(x).train_acc_avg];
            full_results(x).train_acc_std = [full_results(x).train_acc_std,results(x).train_acc_std];
            full_results(x).diff_acc_avg = [full_results(x).diff_acc_avg,results(x).diff_acc_avg];
            full_results(x).diff_acc_std = [full_results(x).diff_acc_std,results(x).diff_acc_std];
            full_results(x).AEC = [full_results(x).AEC,results(x).AEC];
            full_results(x).EC_std = [full_results(x).EC_std,results(x).EC_std];
            full_results(x).ACS = [full_results(x).ACS,results(x).ACS];
            full_results(x).DACS = [full_results(x).DACS,results(x).DACS];
        end
    end
end