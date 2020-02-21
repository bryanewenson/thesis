function full_results = para_gather(n_proc, tag)

    rf_dir = string(pwd) + '\' + "Results[" + tag + "]*";
    result_files = dir(rf_dir);

    load(result_files(1).name);
    full_results = results;

    for x = 2:n_proc
        disp("Processing " + result_files(x).name);

        load(result_files(x).name);

        full_results.test_acc_avg = [full_results.test_acc_avg,results.test_acc_avg];
        full_results.test_acc_std = [full_results.test_acc_std,results.test_acc_std];
        full_results.train_acc_avg = [full_results.train_acc_avg,results.train_acc_avg];
        full_results.train_acc_std = [full_results.train_acc_std,results.train_acc_std];
        full_results.diff_acc_avg = [full_results.diff_acc_avg,results.diff_acc_avg];
        full_results.diff_acc_std = [full_results.diff_acc_std,results.diff_acc_std];
        full_results.AEC = [full_results.AEC,results.AEC];
        full_results.EC_std = [full_results.EC_std,results.EC_std];
        full_results.ACS = [full_results.ACS,results.ACS];
        full_results.DACS = [full_results.DACS,results.DACS];

    end
end