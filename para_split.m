
%n_proc = 10;
%per_proc = [25,25,20,20,15,15,10,10,5,5];
n_proc = 2;
per_proc = [5,10];
proc_trials = zeros(n_proc, max(per_proc));
tag = "newCNN";

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

