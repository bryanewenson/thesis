function plot_info = get_plot_info(plot_type_keyval, results, varargin)

    if nargin == 0
        dataset = results.dataset;
        V_name = results.validation;
        M_name = results.method;
    elseif nargin == 3
        dataset = varargin{1};
        V_name = results.validation{2};
        M_name = results.method{3};
    else
        msg = "Invalid number of arguments to function";
        error(msg);
    end
    
%NEED TO FINISH THIS, NOT FINISHED FIRST CASE

    switch plot_type_keyval
        case 1
            % 1 = Testing and training accuracy over the range of indices
            % of the underlying features.
            
            if strcmp(results.sort_order, 'descend')
                str_order = 'Best';
            else
                str_order = 'Worst';
            end
            
            plot_info.label = "Figure";
            plot_info.title = sprintf("Accuracy of %s in Relation to the %# of %s Features Chosen From the %s Dataset, Using %s Validation", M_name, str_order, dataset, V_name);
            
            plot_info.x(1,:) = results(1).ssp;
            plot_info.y_left(1,:) = results(1).AEC;
  
            plot_info.x_label = "Sample Size Portion";
            plot_info.y_label_left = "Average Error Consistency";
            
            plot_info.force_lim = true;
            plot_info.x_min = min(plot_info.x);
            plot_info.x_max = max(plot_info.x);
            plot_info.y_min_left = min(plot_info.y_left);
            plot_info.y_max_left = max(plot_info.y_left);

            
        case 2
            % 2 = Difference between training and testing accuracy over the
            % average effect size of the underlying features.
            
        case 3
            % 3 = Average error consistency over the average effect size of
            % the underlying features.
            
            plot_info.label_format = "Effect Size - SSP %0.1f%%";
            plot_info.label_args = 100 .* ssp_set;
            plot_info.title_format = sprintf("AEC wrt Average Effect Size of Underlying Features\n%%0.1f%%%% Subsampled From %s Dataset, Using %s %s", dataset, V_name, M_name);
            plot_info.title_args = 100 .* ssp_set;

            for i = 1:n_experiments
                plot_info.x(i,:) = results(i).D_mean;
                plot_info.y_left(i,:) = results(i).AEC;
            end
            plot_info.x_label = "Average Effect Size of Underlying 5 Features";
            plot_info.y_label_left = "Average Error Consistency";
            
            plot_info.force_lim = false;
            
        case 4 
            % 4 = Average error consistency and testing accuracy over the
            % portion of the total sample size used.
            
            plot_info.label = sprintf("Sample Size Portions - %s - %s", M_name, dataset);
            plot_info.title = sprintf("AEC and Average Accuracy wrt Sample Size Portion \n Using %s %s on %s Dataset", V_name, M_name, dataset);

            plot_info.x(1,:) = results(1).ssp;
            plot_info.y_left(1,:) = results(1).AEC;
            plot_info.y_right(1,:) = results(1).test_acc_avg;
  
            plot_info.x_label = "Sample Size Portion";
            plot_info.y_label_left = "Average Error Consistency";
            plot_info.y_label_right = "Test Accuracy";
            
            plot_info.force_lim = false;
            
    end

end
