function fig = plot_results(plot_type_keyval, results, varargin)
%% Parse the argument list
    if nargin == 2
        shared_bounds = false;
    elseif nargin == 3
        shared_bounds = varargin{1};
    else
        msg = "Invalid number of arguments to function";
        error(msg);
    end
    
    n_experiments = size(results,2);

    bp_factor_y = 0.05;
    bp_factor_x = 0.05;
    
    shared_bound_x = shared_bounds;
    shared_bound_y = shared_bounds;
    
%% Determine the appropriate data to be used for each of the plots
    switch plot_type_keyval
        case 1
            % 1 = Testing and training accuracy over the range of indices
            % of the underlying features.

            for exp_idx = 1:n_experiments
                if strcmp(results(exp_idx).sort_order, 'descend')
                    str_order = "Best";
                    plot_x(exp_idx,:) = linspace(results(exp_idx).n_shift + 1, results(exp_idx).n_shift + results(exp_idx).n_select, results(exp_idx).n_select);
                else
                    str_order = "Worst";
                    plot_x(exp_idx,:) = linspace(results(exp_idx).n_shift + results(exp_idx).n_select, results(exp_idx).n_shift + 1, results(exp_idx).n_select);
                end
                plot_y_left(exp_idx,:,1) = results(exp_idx).test_acc_avg;
                plot_y_left(exp_idx,:,2) = results(exp_idx).train_acc_avg;
                            
                fig_label{exp_idx} = sprintf("Feature Range %d-%d %s",plot_x(exp_idx,1),plot_x(exp_idx,end), str_order);
                fig_title{exp_idx} = sprintf("Accuracy of %s When Incrementally Adding the \n%s Features to an Empty Feature Set", results(exp_idx).method, str_order);
            end
            
            fig_label_x = "Rank of Added Features";
            fig_label_y_left = "Average Accuracy (%)";

            legend_items = {'Test Accuracy', 'Train Accuracy'};
            legend_loc = 'northwest';
            
            bp_factor_x = 0;
            shared_bound_x = false;
            
            plotting_handle_left = {@(datax,datay)plot(datax,datay),...
                                    @(datax,datay)plot(datax,datay)};
            
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

            plotting_handle_left = {@(datax,datay)scatter(datax,datay)};
            
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
            
            plotting_handle_left = {@(datax,datay)scatter(datax,datay)};
            plotting_handle_right = {@(datax,datay)plot(datax,datay)};
            
        case 4 
        
            % 4 = Average error consistency and testing accuracy over the
            % portion of the total sample size used.
            
            for exp_idx = 1:n_experiments
                
                fig_label{exp_idx} = sprintf("Error Consistency and Accuracy - Max %0.1f%% SSP - %s %s", 100 * results(exp_idx).ssp(end), results(exp_idx).validation, results(exp_idx).dataset);
                fig_title{exp_idx} = sprintf("AEC and Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", results(exp_idx).validation, results(exp_idx).method, results(exp_idx).dataset);
            
                plot_x(exp_idx,:) = results(exp_idx).ssp;
                plot_y_left(exp_idx,:) = results(exp_idx).AEC;
                plot_y_right(exp_idx,:) = results(exp_idx).test_acc_avg;
            end
            
            fig_label_x = "Sample Size Portion";
            fig_label_y_left = "Average Error Consistency";            
            fig_label_y_right = "Average Testing Accuracy (%)";
            
            plotting_handle_left = {@(datax,datay)scatter(datax,datay)};
            plotting_handle_right = {@(datax,datay)plot(datax,datay)};
       
        case 5
            
            % 5 = Relative Significance Quotient over Effect Size
            
            for exp_idx = 1:n_experiments
                
                fig_label{exp_idx} = sprintf("RSQ - %s %s", results(exp_idx).method, results(exp_idx).dataset);
                fig_title{exp_idx} = sprintf("RSQ of %s wrt Mean Effect Size of the Underlying \n%d Features from the %s Dataset", results(exp_idx).method, results(exp_idx).n_select, results(exp_idx).dataset);
            
                plot_x(exp_idx,:) = results(exp_idx).D_mean;
                plot_y_left(exp_idx,:) = results(exp_idx).DACS;
            end
            
            fig_label_x = "Mean Effect Size";
            fig_label_y_left = "RSQ of Model";            
            
            plotting_handle_left = {@(datax,datay)scatter(datax,datay)};
    end
    
%% Determine the bounds of the axes if they are shared between figures
    if shared_bound_x
        
        bound_x_min = min(plot_x(:));
        bound_x_max = max(plot_x(:));
        padding_x = (bound_x_max - bound_x_min) * bp_factor_x;
    end
    if shared_bound_y
        bound_y_min_left = min(plot_y_left(:));
        bound_y_max_left = max(plot_y_left(:));
        padding_y_left = (bound_y_max_left - bound_y_min_left) * bp_factor_y;
        
        if exist('plot_y_right', 'var')
            bound_y_min_right = min(plot_y_right(:));
            bound_y_max_right = max(plot_y_right(:));
        padding_y_right = (bound_y_max_right - bound_y_min_right) * bp_factor_y;
        end
    end
    
%% Produce a plot for each experiment
    for exp_idx = 1:n_experiments
        if ~shared_bound_x
            bound_x_min = min(plot_x(exp_idx,:));
            bound_x_max = max(plot_x(exp_idx,:));
            padding_x = (bound_x_max - bound_x_min) * bp_factor_x;
        end
        if ~shared_bound_y
            bound_y_min_left = min(plot_y_left(exp_idx,:));
            bound_y_max_left = max(plot_y_left(exp_idx,:));
            padding_y_left = (bound_y_max_left - bound_y_min_left) * bp_factor_y;
            
            if exist('plot_y_right', 'var')
                bound_y_min_right = min(plot_y_right(exp_idx,:));
                bound_y_max_right = max(plot_y_right(exp_idx,:));
                padding_y_right = (bound_y_max_right - bound_y_min_right) * bp_factor_y;
            end
        end

        fig(exp_idx) = figure("Name", fig_label{exp_idx}, "Position", [exp_idx*20 exp_idx*20, 600 500], 'NumberTitle', 'off');

        hold on;

        title(fig_title{exp_idx});
        
        for plot_idx = 1:size(plotting_handle_left,2)
            plotting_handle_left{plot_idx}(plot_x(exp_idx,:), plot_y_left(exp_idx,:,plot_idx));
        end
        
        xlabel(fig_label_x);
        xlim([bound_x_min-padding_x bound_x_max+padding_x]);

        ylabel(fig_label_y_left);
        ylim([bound_y_min_left-padding_y_left bound_y_max_left+padding_y_left]);
        
        if exist('plot_y_right', 'var')
            yyaxis right;

            plotting_handle_right{plot_idx}(plot_x(exp_idx,:), plot_y_right(exp_idx,:));
            ylabel(fig_label_y_right);
            ylim([bound_y_min_right-padding_y_right bound_y_max_right+padding_y_right]);
        end
        
        if plot_type_keyval == 1
            if strcmp(results(exp_idx).sort_order, 'ascend')
                set(gca, 'xdir', 'reverse');
            end
        end
        
        if exist('legend_items','var')
            legend(legend_items, 'Location', legend_loc);
        end
        
        hold off

    end
end
