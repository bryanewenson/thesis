
n_proc = 10;
per_proc = [25,25,20,20,15,15,10,10,5,5];
tag = "SSPMax1000";

%Plot Settings
shared_bounds = false;
plot_type = 2;

proc_trials = zeros(n_proc, max(per_proc));

y = 1;
for z = 1:n_proc
    x = per_proc(z);
    proc_trials(z,1:x) = y : (y + x - 1);

    trials_str = '[';
    for x = 1:per_proc(z)
        trials_str = append(trials_str,int2str(y),',');
        y = y + 1;
    end
    trials_str(end) = ']';
    
    call = "matlab -r main(" + z + "," + trials_str + ",'" + tag + "') &";
    system(call);
end

n_completed = size(dir(string(pwd) + '\' + "Results[" + tag + "]*"),1);

while n_completed < n_proc
    %pause(1800);
    pause(30);
    n_completed = size(dir(string(pwd) + '\' + "Results[" + tag + "]*"),1);
end

results = para_gather(n_proc, tag);

c = fix(clock);
save(sprintf("Results[%s][%d-%d_%d-%d-%d]", tag,...
    c(2), c(3), c(4), c(5), c(6)));

figures = plot_results(plot_type, results, size(results,2), shared_bounds);

save();