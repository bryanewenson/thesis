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

bp_factor = 0.05;
    
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
                fig_label{exp_idx} = "Feature Range - ";
                fig_title{exp_idx} = sprintf("Accuracy of %s in Relation to the %# of %s Features Chosen From the %s Dataset, Using %s Validation", results(exp_idx).method, str_order, results(exp_idx).dataset, results(exp_idx).validation);
            
                plot_x(exp_idx,:) = results(exp_idx).ssp;
                plot_y_left(exp_idx,:) = results(exp_idx).AEC;
            end
            
            fig_label_x = "Sample Size Portion";
            fig_label_y_left = "Average Error Consistency";

            plotting_handle_left = @(datax,datay)plot(datax,datay);
            
            shared_bounds = false;
            
        case 2
            % 2 = Difference between training and testing accuracy over the
            % mean effect size of the underlying features.


            for exp_idx = 1:n_experiments
                fig_label{exp_idx} = sprintf("Accuracy Difference - %s - %d Features (%s Dataset)", results(exp_idx).method, results(exp_idx).n_select, results(exp_idx).dataset);
                fig_title{exp_idx} = sprintf("Difference in Training and Testing Accuracy of %s wrt Effect\nSize of Underlying %d Features (%s Dataset)", results(exp_idx).method, results(exp_idx).n_select, results(exp_idx).dataset);

                plot_x(exp_idx,:) = results(exp_idx).D_mean;
                plot_y_left(exp_idx,:) = results(exp_idx).diff_acc_avg;
            end
            
            fig_label_x = "Mean Effect Size";
            fig_label_y_left = "Average Difference in Accuracy (%)";

            plotting_handle_left = @(datax,datay)scatter(datax,datay);
            
        case 3
        
            % 3 = Average error consistency over the average effect size of
            % the underlying features.
            
            for exp_idx = 1:n_experiments
                fig_label{exp_idx} = sprintf("Effect Size - %0.1f%% SSP", results(exp_idx).ssp_max);
                fig_title{exp_idx} = sprintf("AEC and Accuracy wrt Average Effect Size of Underlying Features\n%0.1f%% Subsampled From %s Dataset Using %s %s", results(exp_idx).ssp_max, results(exp_idx).dataset, results(exp_idx).validation, results(exp_idx).method);
                
                plot_x(exp_idx,:) = results(exp_idx).D_mean;
                plot_y_left(exp_idx,:) = results(exp_idx).AEC;
                plot_y_right(exp_idx,:) = results(exp_idx).test_acc_avg;
            end
            
            fig_label_x = "Average Effect Size of Underlying 5 Features";
            fig_label_y_left = "Average Error Consistency";
            fig_label_y_right = "Average Testing Accuracy (%)";
            
            plotting_handle_left = @(datax,datay)scatter(datax,datay);
            plotting_handle_right = @(datax,datay)plot(datax,datay);
            
        case 4 
        
            % 4 = Average error consistency and testing accuracy over the
            % portion of the total sample size used.
            fig_label = sprintf("Sample Size Portions - %s - %s", method, dataset);
            fig_title = sprintf("AEC and Average Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", results(exp_idx).validation, method, dataset);
            
            for exp_idx = 1:n_experiments
                fig_label = sprintf("Error Consistency and Accuracy - Max %0.1f%% SSP - %s %s", results(exp_idx).ssp_max, results(exp_idx).validation, results(exp_idx).dataset);
                fig_title = sprintf("AEC and Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", results(exp_idx).validation, results(exp_idx).method, results(exp_idx).dataset);
            
                plot_x(exp_idx,:) = results(exp_idx).ssp;
                plot_y_left(exp_idx,:) = results(exp_idx).AEC;
                plot_y_right(exp_idx,:) = results(exp_idx).test_acc_avg;
            end
            
            fig_label_x = "Sample Size Portion";
            fig_label_y_left = "Average Error Consistency";            
            fig_label_y_right = "Average Testing Accuracy (%)";
            
            plotting_handle_left = @(datax,datay)scatter(datax,datay);
            plotting_handle_right = @(datax,datay)plot(datax,datay);
            
    end
    
%% Determine the bounds of the axes if they are shared between figures
    if shared_bounds
        
        bound_x_min = min(plot_x(:));
        bound_x_max = max(plot_x(:));
        padding_x = (bound_x_max - bound_x_min) * bp_factor;
        
        bound_y_min_left = min(plot_y_left(:));
        bound_y_max_left = max(plot_y_left(:));
        padding_y_left = (bound_y_max_left - bound_y_min_left) * bp_factor;
        
        if exist('plot_y_right', 'var')
            bound_y_min_right = min(plot_y_right(:));
            bound_y_max_right = max(plot_y_right(:));
        padding_y_right = (bound_y_max_right - bound_y_min_right) * bp_factor;
        end
        
        
    end
    
%% Produce a plot for each experiment
    for exp_idx = 1:n_experiments
        
         if ~shared_bounds
            bound_x_min = min(plot_x(exp_idx,:));
            bound_x_max = max(plot_x(exp_idx,:));
            padding_x = (bound_x_max - bound_x_min) * bp_factor;
            
            bound_y_min_left = min(plot_y_left(exp_idx,:));
            bound_y_max_left = max(plot_y_left(exp_idx,:));
            padding_y_left = (bound_y_max_left - bound_y_min_left) * bp_factor;
            
            if exist('plot_y_right', 'var')
                bound_y_min_right = min(plot_y_right(exp_idx,:));
                bound_y_max_right = max(plot_y_right(exp_idx,:));
                padding_y_right = (bound_y_max_right - bound_y_min_right) * bp_factor;
            end
         end

        fig(exp_idx) = figure("Name", fig_label{exp_idx}, "Position", [exp_idx*20 exp_idx*20, 600 500], 'NumberTitle', 'off');

        hold on;

        title(fig_title{exp_idx});
        
        plotting_handle_left(plot_x(exp_idx,:), plot_y_left(exp_idx,:));
        
        xlabel(fig_label_x);
        xlim([bound_x_min-padding_x bound_x_max+padding_x]);

        ylabel(fig_label_y_left);
        ylim([bound_y_min_left-padding_y_left bound_y_max_left+padding_y_left]);

        if exist('y_right', 'var')
            yyaxis right;

            plotting_handle_right(plot_x, plot_y_right);
            ylabel(fig_label_y_right);
            ylim([bound_y_min_right-padding_y_right bound_y_max_right+padding_y_right]);
        end

        hold off

    end
end
