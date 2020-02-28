function fig = plot_results(plot_type_keyval, results, varargin)
%% Parse the argument list
    if nargin == 2
        n_experiments = 1;
        shared_bounds = false;
    elseif nargin == 4
        n_experiments = varargin{1};
        shared_bounds = varargin{2};
    else
        msg = "Invalid number of arguments to function";
        error(msg);
    end

%% Determine the appropriate data to be used for each of the plots
    switch plot_type_keyval
        case 1
            % 1 = Testing and training accuracy over the range of indices
            % of the underlying features.

            if strcmp(results.sort_order, 'descend')
                str_order = 'Best';
            else
                str_order = 'Worst';
            end

            for exp_idx = 1:n_experiments
                plot_info.label{exp_idx} = "Feature Range - ";
                plot_info.title{exp_idx} = sprintf("Accuracy of %s in Relation to the %# of %s Features Chosen From the %s Dataset, Using %s Validation", results(exp_idx).method, str_order, results(exp_idx).dataset, results(exp_idx).validation);
            
                plot_info.x(exp_idx,:) = results(exp_idx).ssp;
                plot_info.y_left(exp_idx,:) = results(exp_idx).AEC;
            end
            
            plot_info.x_label = "Sample Size Portion";
            plot_info.y_label_left = "Average Error Consistency";

            plot_info.plot_handle_left = @(datax,datay)plot(datax,datay);
            
            shared_bounds = false;
            
        case 2
            % 2 = Difference between training and testing accuracy over the
            % mean effect size of the underlying features.


            for exp_idx = 1:n_experiments
                plot_info.label{exp_idx} = sprintf("Accuracy Difference - %s - %d Features", results(exp_idx).method, results(exp_idx).n_select);
                plot_info.title{exp_idx} = sprintf("Difference in Training and Testing Accuracy of %s\nwrt Mean Effect Size of Underlying %d Features", results(exp_idx).method, results(exp_idx).n_select);

                plot_info.x(exp_idx,:) = results(exp_idx).D_mean;
                plot_info.y_left(exp_idx,:) = results(exp_idx).diff_acc_avg;
            end
            
            plot_info.plot_handle_left = @(datax,datay)scatter(datax,datay);
            
            plot_info.x_label = "Mean Effect Size";
            plot_info.y_label_left = "Average Difference in Accuracy (%)";

            plot_info.plot_handle_left = @(datax,datay)scatter(datax,datay);
            
        case 3
        
            % 3 = Average error consistency over the average effect size of
            % the underlying features.
            
            for exp_idx = 1:n_experiments
                plot_info.label{exp_idx} = sprintf("Effect Size - %0.1f%% SSP", results(exp_idx).ssp_max);
                plot_info.title{exp_idx} = sprintf("AEC and Accuracy wrt Average Effect Size of Underlying Features\n%0.1f%% Subsampled From %s Dataset Using %s %s", results(exp_idx).ssp_max, results(exp_idx).dataset, results(exp_idx).validation, results(exp_idx).method);
                
                plot_info.x(exp_idx,:) = results(exp_idx).D_mean;
                plot_info.y_left(exp_idx,:) = results(exp_idx).AEC;
                plot_info.y_right(exp_idx,:) = results(exp_idx).test_acc_avg;
            end
            
            plot_info.x_label = "Average Effect Size of Underlying 5 Features";
            plot_info.y_label_left = "Average Error Consistency";
            plot_info.y_label_right = "Average Testing Accuracy (%)";
            
            plot_info.plot_handle_left = @(datax,datay)scatter(datax,datay);
            plot_info.plot_handle_right = @(datax,datay)plot(datax,datay);
            
        case 4 
        
            % 4 = Average error consistency and testing accuracy over the
            % portion of the total sample size used.
            plot_info.label = sprintf("Sample Size Portions - %s - %s", method, dataset);
            plot_info.title = sprintf("AEC and Average Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", results(exp_idx).validation, method, dataset);
            
            for exp_idx = 1:n_experiments
                plot_info.label = sprintf("Error Consistency and Accuracy - Max %0.1f%% SSP - %s %s", results(exp_idx).ssp_max, results(exp_idx).validation, results(exp_idx).dataset);
                plot_info.title = sprintf("AEC and Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", results(exp_idx).validation, results(exp_idx).method, results(exp_idx).dataset);
            
                plot_info.x(exp_idx,:) = results(exp_idx).ssp;
                plot_info.y_left(exp_idx,:) = results(exp_idx).AEC;
                plot_info.y_right(exp_idx,:) = results(exp_idx).test_acc_avg;
            end
            
            plot_info.x_label = "Sample Size Portion";
            plot_info.y_label_left = "Average Error Consistency";            
            plot_info.y_label_right = "Average Testing Accuracy (%)";
            
            plot_info.plot_handle_left = @(datax,datay)scatter(datax,datay);
            plot_info.plot_handle_right = @(datax,datay)plot(datax,datay);
            
    end
    
%% Determine the bounds of the axes if they are shared between figures
    if shared_bounds && n_experiments > 1
        
        plot_info.x_min = min(plot_info.x(:));
        plot_info.x_max = max(plot_info.x(:));
        
        plot_info.y_left_min = min(plot_info.y_left(:));
        plot_info.y_left_max = max(plot_info.y_left(:));
        
        if isfield(plot_info, 'y_right')
            plot_info.y_right_min = min(plot_info.y_right(:));
            plot_info.y_right_max = max(plot_info.y_right(:));
        end
        
    end
    
%% Produce a plot for each experiment
    for exp_idx = 1:n_experiments
        
         if ~shared_bounds
            plot_info.x_min = min(plot_info.x(exp_idx,:));
            plot_info.x_max = max(plot_info.x(exp_idx,:));
            plot_info.y_min_left = min(plot_info.y_left(exp_idx,:));
            plot_info.y_max_left = max(plot_info.y_left(exp_idx,:));

            if isfield(plot_info, 'y_right')
                plot_info.y_min_right = min(plot_info.y_right(exp_idx,:));
                plot_info.y_max_right = max(plot_info.y_right(exp_idx,:));

            end
         end

        fig(exp_idx) = figure("Name", plot_info.label{exp_idx}, "Position", [exp_idx*20 exp_idx*20, 600 500], 'NumberTitle', 'off');

        hold on;

        title(plot_info.title{exp_idx});
        
        plot_info.plot_handle_left(plot_info.x(exp_idx,:), plot_info.y_left(exp_idx,:));
        
        xlabel(plot_info.x_label);
        xlim([plot_info.x_min plot_info.x_max]);

        ylabel(plot_info.y_label_left);
        ylim([plot_info.y_left_min plot_info.y_left_max]);

        if isfield(plot_info, 'y_right')
            yyaxis right;

            plot_info.plot_handle_right(plot_info.x, plot_info.y_right);
            ylabel(plot_info.y_label_right);
            ylim([plot_info.y_right_min plot_info.y_right_max]);
        end

        hold off

    end
end
